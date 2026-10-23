/// How a pass built its prompt.
enum AiPromptPath {
  /// A Firebase AI Logic server prompt template.
  template,

  /// The client-built prompt with the Remote Config model.
  client,
}

/// Which prompt path, and which template or model, one pass ran with.
class AiPassRun {
  /// A run through the server prompt template [templateId].
  ///
  /// The model is set in the template itself, and the SDK does not report
  /// back which model answered, so it is not recorded here.
  const AiPassRun.template({
    required this.pass,
    required String this.templateId,
  }) : path = AiPromptPath.template,
       model = null;

  /// A run through the client-built prompt with [model].
  const AiPassRun.client({required this.pass, required String this.model})
    : path = AiPromptPath.client,
      templateId = null;

  /// The pass name, e.g. `research` or `format`.
  final String pass;
  final AiPromptPath path;
  final String? templateId;
  final String? model;

  /// For example `template:travel-research` or `client:gemini-3.5-flash`.
  String get label => switch (path) {
    AiPromptPath.template => 'template:$templateId',
    AiPromptPath.client => 'client:$model',
  };
}

/// Collects the [AiPassRun]s of the travel plan generation in progress.
///
/// Shared by the passes, which know which path they take, and the repository,
/// which reports the generation to analytics and error monitoring.
class AiRunRecorder {
  final Map<String, AiPassRun> _runs = {};

  /// Forgets the runs of the previous generation.
  void reset() => _runs.clear();

  /// Records [run], replacing an earlier run of the same pass, e.g. a template
  /// attempt that fell back to the client-built prompt.
  void record(AiPassRun run) => _runs[run.pass] = run;

  /// The recorded runs in the order the passes started.
  List<AiPassRun> get runs => List.unmodifiable(_runs.values);

  /// For example `research=template:travel-research, format=client:gemini-x`.
  String describe() =>
      _runs.values.map((run) => '${run.pass}=${run.label}').join(', ');
}
