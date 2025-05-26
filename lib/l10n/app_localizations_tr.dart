// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Seyahat Asistanı';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String travelFormStepTitle(int stepNumber) {
    return 'Adım $stepNumber';
  }

  @override
  String get departureAirportStepTitle => 'Nereden uçuyorsunuz?';

  @override
  String get departureAirportHintText =>
      'Kalkış havalimanı ara (ör. IST, İstanbul)';

  @override
  String get arrivalAirportStepTitle => 'Nereye uçuyorsunuz?';

  @override
  String get arrivalAirportHintText =>
      'Varış havalimanı ara (ör. JFK, New York)';

  @override
  String get travelDatesStepTitle => 'Ne zaman seyahat ediyorsunuz?';

  @override
  String get selectDatesButtonLabel => 'Seyahat Tarihlerini Seç';

  @override
  String selectedDatesLabel(String startDate, String endDate) {
    return 'Seçilen: $startDate - $endDate';
  }

  @override
  String get noDatesSelected => 'Tarih seçilmedi';

  @override
  String get nationalityStepTitle => 'Milliyetiniz nedir?';

  @override
  String get nationalityHintText => 'Milliyetinizi arayın (ör. TR, ABD)';

  @override
  String selectedNationalityLabel(String nationalityName) {
    return 'Seçilen: $nationalityName';
  }

  @override
  String get travelPurposeStepTitle => 'Seyahat amaçlarınız nelerdir?';

  @override
  String get selectTravelPurposes => 'Seyahat Amaçlarını Seçin';

  @override
  String get selectTravelPurposesDescription =>
      'Seyahatiniz için bir veya daha fazla amaç seçin. Bu, daha iyi öneriler sunmamıza yardımcı olur.';

  @override
  String get selectedPurposes => 'Seçilen Amaçlar';

  @override
  String get noPurposesAvailable =>
      'Seyahat amaçları bulunamadı. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get travelFormErrorTitle => 'Hata Oluştu';

  @override
  String validationErrorTravelPurposeMissing(
    int selectedTravelPurposes,
    int minimumTravelPurposes,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      minimumTravelPurposes,
      locale: localeName,
      other:
          'Lütfen en az $minimumTravelPurposes seyahat amacı seçin. $selectedTravelPurposes adet seçtiniz.',
      one:
          'Lütfen en az 1 seyahat amacı seçin. $selectedTravelPurposes adet seçtiniz.',
    );
    return '$_temp0';
  }

  @override
  String validationErrorTravelPurposeTooMany(
    int selectedTravelPurposes,
    int maximumTravelPurposes,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      maximumTravelPurposes,
      locale: localeName,
      other:
          'Lütfen en fazla $maximumTravelPurposes seyahat amacı seçin. $selectedTravelPurposes adet seçtiniz.',
      one:
          'Lütfen en fazla 1 seyahat amacı seçin. $selectedTravelPurposes adet seçtiniz.',
    );
    return '$_temp0';
  }

  @override
  String get validationErrorNationalityMissing => 'Lütfen milliyetinizi seçin.';

  @override
  String get errorInvalidDateRange =>
      'Bitiş tarihi başlangıç tarihinden önce olamaz.';

  @override
  String get validationErrorDepartureAirportMissing =>
      'Lütfen bir kalkış havalimanı seçin.';

  @override
  String get validationErrorArrivalAirportMissing =>
      'Lütfen bir varış havalimanı seçin.';

  @override
  String get validationErrorDateRangeMissing =>
      'Lütfen seyahat tarihlerini seçin.';

  @override
  String get errorGeneralTravelForm =>
      'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorServer =>
      'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';

  @override
  String selectedAirportLabel(String airportName, String airportCode) {
    return 'Seçilen: $airportName ($airportCode)';
  }

  @override
  String get navigationPrevious => 'Önceki';

  @override
  String get navigationNext => 'Sonraki';

  @override
  String get navigationSubmit => 'Seyahat Planı Al';

  @override
  String get submittingForm => 'Mükemmel maceranızı hazırlıyorum...';

  @override
  String get yourTravelPlan => 'Seyahat Planınız';

  @override
  String get fromLabel => 'Nereden';

  @override
  String get toLabel => 'Nereye';

  @override
  String get datesLabel => 'Tarihler';

  @override
  String get nationalityLabel => 'Milliyet';

  @override
  String get travelPurposesLabel => 'Seyahat Amaçları';

  @override
  String get recommendationsTitle => 'Öneriler';

  @override
  String get planAnotherTrip => 'Başka Bir Seyahat Planla';

  @override
  String flightDurationFormat(int hours, int minutes) {
    return '${hours}s ${minutes}d';
  }

  @override
  String get flightOptionsTitle => 'Uçuş Seçenekleri';

  @override
  String get cheapestOptionTitle => 'En Uygun Seçenek';

  @override
  String get comfortableOptionTitle => 'Rahat Seçenek';

  @override
  String get recommendedOptionTitle => 'Önerilen Seçenek';

  @override
  String get outboundFlightLabel => 'Gidiş Uçuşu';

  @override
  String get returnFlightLabel => 'Dönüş Uçuşu';

  @override
  String stopsLabel(int count) {
    return '$count durak';
  }

  @override
  String stopsCountLabel(int count) {
    return 'Duraklar: $count';
  }

  @override
  String get cityInformationTitle => 'Şehir Bilgisi';

  @override
  String get cityCardCrowdLevelLabel => 'Kalabalık Seviyesi';

  @override
  String get cityCardWeatherForecastTitle => 'Hava Durumu Tahmini';

  @override
  String photoAttributionFormat(String photographerName) {
    return 'Fotoğraf: $photographerName (Unsplash)';
  }

  @override
  String get disclaimerAIMistakesTitle => 'Önemli Uyarı';

  @override
  String get disclaimerAIMistakesContent =>
      'Sağlanan seyahat bilgileri yapay zeka tarafından üretilmiştir ve yanlışlıklar veya eksiklikler içerebilir. Herhangi bir seyahat planı yapmadan önce vize gereksinimleri, uçuş programları ve güvenlik uyarıları gibi kritik bilgileri her zaman resmi kaynaklardan doğrulayın.';

  @override
  String get disclaimerLegalTitle => 'Yasal Uyarı';

  @override
  String get disclaimerLegalContent =>
      'Bu uygulama yalnızca genel rehberlik amacıyla seyahat yardımı ve bilgileri sağlar. Bu bilgilerin kullanımından kaynaklanan herhangi bir hata, eksiklik veya sorundan sorumlu değiliz. Kullanıcılar seyahat kararlarından ve tüm bilgileri resmi ve güvenilir kaynaklardan doğrulamaktan yalnızca kendileri sorumludur.';

  @override
  String get stepTitleWelcome => 'Bir sonraki maceranızı planlayalım!';

  @override
  String get stepTitleArrival => 'Maceranız sizi nereye götürecek?';

  @override
  String get stepTitleDates => 'Sihir ne zaman gerçekleşecek?';

  @override
  String get stepTitleNationality => 'Bize kendinizden bahsedin!';

  @override
  String get stepTitlePurpose => 'Sizi keşfe çağıran nedir?';

  @override
  String get stepTitleReview => 'Neredeyse bitti!';

  @override
  String get stepDescriptionDeparture =>
      'Yolculuğunuz nerede başlayacak? Başlamak için kalkış havalimanınızı girin.';

  @override
  String get stepDescriptionArrival =>
      'Nereye gidiyorsunuz? Havalimanı önerilerimizden varış hedefinizi seçin.';

  @override
  String get stepDescriptionDates =>
      'Ne zaman seyahat etmek istiyorsunuz? Gidiş ve dönüş tarihlerinizi seçin.';

  @override
  String get stepDescriptionNationality =>
      'Milliyetiniz nedir? Bu, doğru vize ve seyahat gereksinimlerini sağlamamıza yardımcı olur.';

  @override
  String get stepDescriptionPurpose =>
      'Seyahatinizin amacı nedir? Kişiselleştirilmiş öneriler almak için uygun olanların tümünü seçin.';

  @override
  String get stepDescriptionReview =>
      'Aşağıdaki seyahat detaylarınızı gözden geçirin ve AI tarafından oluşturulan seyahat planınızı alın!';

  @override
  String get currencyInformationTitle => 'Para Birimi Bilgisi';

  @override
  String get currencyLabel => 'Para Birimi';

  @override
  String get exchangeRateLabel => 'Döviz Kuru';

  @override
  String get averageDailyCostLabel => 'Ortalama Günlük Maliyet';

  @override
  String get taxInformationTitle => 'Vergi Bilgisi';

  @override
  String get taxRateLabel => 'Vergi Oranı';

  @override
  String get taxFreeShoppingLabel => 'Vergisiz Alışveriş';

  @override
  String get availableLabel => 'Mevcut';

  @override
  String get notAvailableLabel => 'Mevcut Değil';

  @override
  String get placesToVisitTitle => 'Gezilecek Yerler';

  @override
  String get requirementsLabel => 'Gereksinimler:';

  @override
  String get closeLabel => 'Kapat';

  @override
  String get travelItineraryTitle => 'Seyahat Programı';
}
