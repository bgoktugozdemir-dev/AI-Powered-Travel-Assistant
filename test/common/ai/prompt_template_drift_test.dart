import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart' show Schema;
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/function_declarations.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:yaml/yaml.dart';

/// Guards the Firebase AI Logic server prompt templates in
/// `firebase/prompt_templates/` against drifting away from the schemas the app
/// is built on:
///
/// * the format template output schema vs `TravelDetails.aiSchema`
/// * the research template tools vs `FunctionDeclarations`
///
/// Descriptions are not compared, only the structure the app depends on:
/// property names, types, nesting, optional/nullable and enum values.
abstract class _Constants {
  static const String templatesDirectory = 'firebase/prompt_templates';
  static const String researchTemplate = 'travel-research.prompt';
  static const String formatTemplate = 'travel-format.prompt';

  /// `name`, optional `?`, optional `(type, description)` of a Picoschema key.
  static final RegExp picoKey = RegExp(
    r'^([^?(]+)(\?)?(?:\(([^,)]+)(?:,.*)?\))?$',
  );

  static final RegExp frontmatter = RegExp(r'^---\n([\s\S]*?)\n---\n');
  static final RegExp templateVariable = RegExp(
    r'\{\{\s*([A-Za-z_]\w*)\s*\}\}',
  );
}

class _Template {
  _Template(this.frontmatter, this.body);

  final YamlMap frontmatter;
  final String body;

  static _Template load(String fileName) {
    final source = File(
      '${_Constants.templatesDirectory}/$fileName',
    ).readAsStringSync();
    final match = _Constants.frontmatter.firstMatch(source);
    expect(match, isNotNull, reason: '$fileName must start with frontmatter');
    return _Template(
      loadYaml(match!.group(1)!) as YamlMap,
      source.substring(match.end),
    );
  }
}

/// One line per schema node, for example
/// `city.time: object optional=true nullable=true`.
Set<String> _flattenSchemaJson(Map<String, Object?> json, String path) {
  final lines = <String>{};

  void visit(Map<String, Object?> node, String path, {required bool optional}) {
    final enumValues = (node['enum'] as List<Object?>?)?.cast<String>();
    final type = enumValues != null
        ? 'enum(${(enumValues.toList()..sort()).join('|')})'
        : (node['type']! as String).toLowerCase();
    final nullable = node['nullable'] == true;
    lines.add('$path: $type optional=$optional nullable=$nullable');

    if (node['properties'] case final Map<String, Object?> properties) {
      final required = (node['required'] as List<Object?>? ?? [])
          .cast<String>();
      for (final MapEntry(:key, :value) in properties.entries) {
        visit(
          value! as Map<String, Object?>,
          '$path.$key',
          optional: !required.contains(key),
        );
      }
    }
    if (node['items'] case final Map<String, Object?> items) {
      visit(items, '$path[]', optional: false);
    }
  }

  visit(json, path, optional: false);
  return lines;
}

/// Same output as [_flattenSchemaJson] for a Picoschema property map.
Set<String> _flattenPicoschema(YamlMap schema, String path) {
  final lines = <String>{'$path: object optional=false nullable=false'};

  void addScalar(String path, String type, {required bool optional}) {
    lines.add('$path: $type optional=$optional nullable=$optional');
  }

  void visitProperties(YamlMap properties, String path) {
    for (final MapEntry(:key, :value) in properties.entries) {
      final match = _Constants.picoKey.firstMatch(key as String);
      expect(match, isNotNull, reason: 'Unsupported Picoschema key: $key');
      final name = match!.group(1)!.trim();
      final optional = match.group(2) != null;
      final declaredType = match.group(3)?.trim();
      final propertyPath = '$path.$name';

      switch (declaredType) {
        case 'object':
          addScalar(propertyPath, 'object', optional: optional);
          visitProperties(value as YamlMap, propertyPath);
        case 'array':
          addScalar(propertyPath, 'array', optional: optional);
          if (value is YamlMap) {
            addScalar('$propertyPath[]', 'object', optional: false);
            visitProperties(value, '$propertyPath[]');
          } else {
            addScalar('$propertyPath[]', _scalarType(value), optional: false);
          }
        case 'enum':
          final values = (value as YamlList).cast<String>().toList()..sort();
          addScalar(
            propertyPath,
            'enum(${values.join('|')})',
            optional: optional,
          );
        case null:
          addScalar(propertyPath, _scalarType(value), optional: optional);
        default:
          fail('Unsupported Picoschema type "$declaredType" at $propertyPath');
      }
    }
  }

  visitProperties(schema, path);
  return lines;
}

/// `string, a description` -> `string`.
String _scalarType(Object? value) => (value! as String).split(',').first.trim();

void main() {
  group('travel-format template', () {
    late _Template template;

    setUpAll(() => template = _Template.load(_Constants.formatTemplate));

    test('declares JSON structured output', () {
      final output = template.frontmatter['output'] as YamlMap?;

      expect(output, isNotNull);
      expect(output!['format'], 'json');
      expect(output['schema'], isA<YamlMap>());
    });

    test('output schema matches TravelDetails.aiSchema', () {
      final output = template.frontmatter['output'] as YamlMap;
      final fromTemplate = _flattenPicoschema(
        output['schema'] as YamlMap,
        'root',
      );
      final fromApp = _flattenSchemaJson(
        TravelDetails.aiSchema.toJson(),
        'root',
      );

      expect(
        fromApp.difference(fromTemplate),
        isEmpty,
        reason:
            'In TravelDetails.aiSchema but missing or different in the '
            'template. Update ${_Constants.formatTemplate}.',
      );
      expect(
        fromTemplate.difference(fromApp),
        isEmpty,
        reason:
            'In the template but missing or different in '
            'TravelDetails.aiSchema. Update ${_Constants.formatTemplate}.',
      );
    });

    test('declares every input variable used by the prompt', () {
      expect(
        _declaredInputs(template),
        containsAll(_usedVariables(template)),
      );
    });
  });

  group('travel-research template', () {
    late _Template template;

    setUpAll(() => template = _Template.load(_Constants.researchTemplate));

    test('declares every input variable used by the prompt', () {
      expect(
        _declaredInputs(template),
        containsAll(_usedVariables(template)),
      );
    });

    test('keeps the chat history in the prompt', () {
      expect(template.body, contains('{{history}}'));
    });

    test('tools match FunctionDeclarations', () {
      final tools = (template.frontmatter['tools'] as YamlList).cast<YamlMap>();

      // Picoschema makes optional parameters nullable, function declarations
      // do not. Nullability does not matter for call arguments.
      final fromTemplate = <String>{
        for (final tool in tools)
          ..._flattenPicoschema(
            (tool['input'] as YamlMap)['schema'] as YamlMap,
            tool['name'] as String,
          ).map(_withoutNullable),
      };
      final fromApp = <String>{
        for (final declaration in FunctionDeclarations.all)
          ..._flattenSchemaJson(
            declaration.toJson()['parameters']! as Map<String, Object?>,
            declaration.name,
          ).map(_withoutNullable),
      };

      expect(
        fromApp.difference(fromTemplate),
        isEmpty,
        reason:
            'In FunctionDeclarations but missing or different in the '
            'template. Update ${_Constants.researchTemplate}.',
      );
      expect(
        fromTemplate.difference(fromApp),
        isEmpty,
        reason:
            'In the template but missing or different in '
            'FunctionDeclarations. Update ${_Constants.researchTemplate}.',
      );
    });
  });

  test('schema flattening detects differences', () {
    final original = _flattenSchemaJson(
      Schema.object(
        properties: {
          'a': Schema.string(),
          'b': Schema.integer(nullable: true),
        },
        optionalProperties: ['b'],
      ).toJson(),
      'root',
    );
    final changed = _flattenSchemaJson(
      Schema.object(
        properties: {
          'a': Schema.string(),
          'b': Schema.number(nullable: true),
        },
        optionalProperties: ['b'],
      ).toJson(),
      'root',
    );

    expect(original.difference(changed), isNotEmpty);
  });
}

String _withoutNullable(String line) =>
    line.replaceFirst(RegExp(r' nullable=\w+$'), '');

Set<String> _declaredInputs(_Template template) {
  final input = template.frontmatter['input'] as YamlMap?;
  final schema = input?['schema'] as YamlMap? ?? YamlMap();
  return {
    for (final key in schema.keys)
      _Constants.picoKey.firstMatch(key as String)!.group(1)!.trim(),
  };
}

Set<String> _usedVariables(_Template template) {
  const helpers = {'role', 'history'};
  return {
    for (final match in _Constants.templateVariable.allMatches(template.body))
      if (!helpers.contains(match.group(1)!)) match.group(1)!,
  };
}
