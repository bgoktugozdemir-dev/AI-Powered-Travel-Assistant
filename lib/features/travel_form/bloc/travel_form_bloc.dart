import 'dart:async'; // For Future

// Added
import 'package:flutter_bloc/flutter_bloc.dart';
// For Dio and DioError
import 'package:equatable/equatable.dart'; // For ValueGetter
import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model
import 'package:travel_assistant/common/models/country.dart'; // Import Country model
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart'; // Import TravelPurpose model
import 'package:travel_assistant/common/repositories/airport_repository.dart'; // Import repository
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/gemini_repository.dart';
import 'package:travel_assistant/common/repositories/image_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
// Import service for direct instantiation (temp)
// Import the interceptor
import 'package:travel_assistant/common/services/country_service.dart'; // Import CountryService
import 'package:travel_assistant/common/services/travel_purpose_service.dart'; // Import TravelPurposeService
import 'package:rxdart/rxdart.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart'; // Added

part 'travel_form_event.dart';
part 'travel_form_state.dart';

/// {@template travel_form_bloc}
/// Manages the state for the travel input form.
/// {@endtemplate}
class TravelFormBloc extends Bloc<TravelFormEvent, TravelFormState> {
  final CountryService _countryService;
  final TravelPurposeService _travelPurposeService;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;
  final GeminiRepository _geminiRepository;
  final AirportRepository _airportRepository;
  final UnsplashRepository _unsplashRepository;
  final CurrencyRepository _currencyRepository;
  final ImageRepository _imageRepository;

  TravelFormBloc({
    required AirportRepository airportRepository,
    required TravelPurposeService travelPurposeService,
    required GeminiRepository geminiRepository,
    required UnsplashRepository unsplashRepository,
    required ImageRepository imageRepository,
    required CurrencyRepository currencyRepository,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
    CountryService? countryService,
  }) : _airportRepository = airportRepository,
       _travelPurposeService = travelPurposeService,
       _geminiRepository = geminiRepository,
       _unsplashRepository = unsplashRepository,
       _imageRepository = imageRepository,
       _currencyRepository = currencyRepository,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
       _countryService = CountryService(),
       super(const TravelFormState()) {
    on<TravelFormInitializeServices>(_onInitializeServices);

    // Transformation for debouncing airport search
    on<TravelFormDepartureAirportSearchTermChanged>(
      _onDepartureAirportSearchTermChanged,
      transformer:
          (events, mapper) => events
              .switchMap(mapper)
              .debounceTime(
                const Duration(milliseconds: 300),
              ),
    );

    on<TravelFormArrivalAirportSearchTermChanged>(
      _onArrivalAirportSearchTermChanged,
      transformer:
          (events, mapper) => events
              .switchMap(mapper)
              .debounceTime(
                const Duration(milliseconds: 300),
              ),
    );

    on<TravelFormNationalitySearchTermChanged>(
      _onNationalitySearchTermChanged,
      transformer:
          (events, mapper) => events
              .switchMap(mapper)
              .debounceTime(
                const Duration(milliseconds: 300),
              ),
    );

    // Form Events
    on<TravelFormStarted>(_onStarted);
    on<TravelFormNextStepRequested>(_onNextStepRequested);
    on<TravelFormPreviousStepRequested>(_onPreviousStepRequested);

    // Airport Events
    on<TravelFormDepartureAirportSelected>(_onDepartureAirportSelected);
    on<TravelFormArrivalAirportSelected>(_onArrivalAirportSelected);

    // Date Events
    on<TravelFormDateRangeSelected>(_onDateRangeSelected);

    // Nationality Events
    on<TravelFormNationalitySelected>(_onNationalitySelected);

    // Travel Purposes Events
    on<LoadTravelPurposesEvent>(_onLoadTravelPurposes);
    on<ToggleTravelPurposeEvent>(_onToggleTravelPurpose);

    // Form Submission
    on<SubmitTravelFormEvent>(_onSubmitTravelForm);

    // Country Service Retry
    on<RetryCountryServiceEvent>(_onRetryCountryService);

    // Initialize services
    add(const TravelFormInitializeServices());
  }

  /// Initialize all required services
  Future<void> _onInitializeServices(
    TravelFormInitializeServices event,
    Emitter<TravelFormState> emit,
  ) async {
    emit(state.copyWith(countryServiceStatus: CountryServiceStatus.loading));
    try {
      await _countryService.initialize();
      emit(state.copyWith(countryServiceStatus: CountryServiceStatus.success));
    } catch (e) {
      appLogger.e('Failed to initialize CountryService', error: e);
      emit(
        state.copyWith(
          countryServiceStatus: CountryServiceStatus.failure,
          error: () => CountryServiceError(),
        ),
      );
    }
  }

  void _onStarted(TravelFormStarted event, Emitter<TravelFormState> emit) {
    emit(const TravelFormState());
  }

  void _onNextStepRequested(
    TravelFormNextStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    if (state.currentStep == 0 && state.selectedDepartureAirport == null) {
      emit(state.copyWith(error: () => DepartureAirportMissingError()));
      return;
    } else if (state.currentStep == 1 && state.selectedArrivalAirport == null) {
      emit(state.copyWith(error: () => ArrivalAirportMissingError()));
      return;
    } else if (state.currentStep == 2 && state.selectedDateRange == null) {
      emit(state.copyWith(error: () => DateRangeMissingError()));
      return;
    } else if (state.currentStep == 3 && state.selectedNationality == null) {
      emit(state.copyWith(error: () => NationalityMissingError()));
      return;
    } else if (state.currentStep == 4) {
      final selectedTravelPurposes = state.selectedTravelPurposes.length;
      final minimumTravelPurposes = _firebaseRemoteConfigRepository.minimumTravelPurposes;
      final maximumTravelPurposes = _firebaseRemoteConfigRepository.maximumTravelPurposes;
      if (selectedTravelPurposes < minimumTravelPurposes) {
        emit(
          state.copyWith(
            error:
                () => TravelPurposeMissingError(
                  selectedTravelPurposes,
                  minimumTravelPurposes,
                ),
          ),
        );
        return;
      } else if (selectedTravelPurposes > maximumTravelPurposes) {
        emit(
          state.copyWith(
            error:
                () => TravelPurposeTooManyError(
                  selectedTravelPurposes,
                  maximumTravelPurposes,
                ),
          ),
        );
        return;
      }
    }

    if (state.currentStep < state.totalSteps - 1) {
      appLogger.i("Validation passed, moving to next step.");
      emit(
        state.copyWith(currentStep: state.currentStep + 1, error: () => null),
      );
    }
  }

  void _onPreviousStepRequested(
    TravelFormPreviousStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(
        state.copyWith(currentStep: state.currentStep - 1, error: () => null),
      );
    }
  }

  // --- Departure Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onDepartureAirportSearchTermChanged(
    TravelFormDepartureAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    // Made async
    emit(
      state.copyWith(
        departureAirportSearchTerm: event.searchTerm,
        selectedDepartureAirport: () => null,
      ),
    );

    if (event.searchTerm.length < 3) {
      emit(
        state.copyWith(
          departureAirportSuggestions: [],
          isDepartureAirportLoading: false,
        ),
      );
      return;
    }
    emit(state.copyWith(isDepartureAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(
        event.searchTerm,
      );

      emit(
        state.copyWith(
          departureAirportSuggestions: suggestions,
          isDepartureAirportLoading: false,
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDepartureAirportLoading: false,
          departureAirportSuggestions: [],
          error: () => GeneralTravelFormError(),
        ),
      );
    }
  }

  void _onDepartureAirportSelected(
    TravelFormDepartureAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDepartureAirport: () => event.airport,
        departureAirportSearchTerm: event.airport.name,
        departureAirportSuggestions: [],
      ),
    );

    if (_firebaseRemoteConfigRepository.navigateToNextStepAfterSelectingTravelPurpose) {
      add(TravelFormNextStepRequested());
    }
  }

  // --- Arrival Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onArrivalAirportSearchTermChanged(
    TravelFormArrivalAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    // Made async
    emit(
      state.copyWith(
        arrivalAirportSearchTerm: event.searchTerm,
        selectedArrivalAirport: () => null,
      ),
    );

    if (event.searchTerm.length < 3) {
      emit(
        state.copyWith(
          arrivalAirportSuggestions: [],
          isArrivalAirportLoading: false,
        ),
      );
      return;
    }
    emit(state.copyWith(isArrivalAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(
        event.searchTerm,
      );
      emit(
        state.copyWith(
          arrivalAirportSuggestions: suggestions,
          isArrivalAirportLoading: false,
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isArrivalAirportLoading: false,
          arrivalAirportSuggestions: [],
          error: () => GeneralTravelFormError(),
        ),
      );
    }
  }

  void _onArrivalAirportSelected(
    TravelFormArrivalAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedArrivalAirport: () => event.airport,
        arrivalAirportSearchTerm: event.airport.name,
        arrivalAirportSuggestions: [],
      ),
    );

    if (_firebaseRemoteConfigRepository.navigateToNextStepAfterSelectingTravelPurpose) {
      add(TravelFormNextStepRequested());
    }
  }

  // --- Travel Dates Handler ---
  void _onDateRangeSelected(
    TravelFormDateRangeSelected event,
    Emitter<TravelFormState> emit,
  ) {
    if (event.dateRange.end.isBefore(event.dateRange.start)) {
      emit(state.copyWith(error: () => DateRangeInvalidError()));
      return;
    }
    emit(
      state.copyWith(
        selectedDateRange: () => event.dateRange,
        error: () => null,
      ),
    );

    if (_firebaseRemoteConfigRepository.navigateToNextStepAfterSelectingTravelPurpose) {
      add(TravelFormNextStepRequested());
    }
  }

  // --- Nationality Handlers ---
  Future<void> _onNationalitySearchTermChanged(
    TravelFormNationalitySearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    emit(
      state.copyWith(
        nationalitySearchTerm: event.searchTerm,
        selectedNationality: () => null,
      ),
    );

    if (event.searchTerm.length < 2) {
      emit(
        state.copyWith(nationalitySuggestions: [], isNationalityLoading: false),
      );
      return;
    }

    // Check if country service is available
    if (state.countryServiceStatus != CountryServiceStatus.success) {
      emit(
        state.copyWith(
          isNationalityLoading: false,
          nationalitySuggestions: [],
          error: () => CountryServiceError(),
        ),
      );
      return;
    }

    emit(state.copyWith(isNationalityLoading: true));

    try {
      final suggestions = await _countryService.searchCountries(
        event.searchTerm,
      );
      emit(
        state.copyWith(
          nationalitySuggestions: suggestions,
          isNationalityLoading: false,
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isNationalityLoading: false,
          nationalitySuggestions: [],
          error: () => CountryServiceError(),
        ),
      );
    }
  }

  void _onNationalitySelected(
    TravelFormNationalitySelected event,
    Emitter<TravelFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedNationality: () => event.country,
        nationalitySearchTerm: event.country.name,
        nationalitySuggestions: [],
      ),
    );

    if (_firebaseRemoteConfigRepository.navigateToNextStepAfterSelectingTravelPurpose) {
      add(TravelFormNextStepRequested());
    }
  }

  // --- Travel Purpose Handlers ---
  Future<void> _onLoadTravelPurposes(
    LoadTravelPurposesEvent event,
    Emitter<TravelFormState> emit,
  ) async {
    emit(state.copyWith(isTravelPurposesLoading: true));

    try {
      final purposes = await _travelPurposeService.getTravelPurposes();
      emit(
        state.copyWith(
          availableTravelPurposes: purposes,
          isTravelPurposesLoading: false,
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isTravelPurposesLoading: false,
          error: () => GeneralTravelFormError(),
        ),
      );
    }
  }

  void _onToggleTravelPurpose(
    ToggleTravelPurposeEvent event,
    Emitter<TravelFormState> emit,
  ) {
    final currentPurposes = List<TravelPurpose>.from(
      state.selectedTravelPurposes,
    );

    if (event.isSelected) {
      // Add purpose if not already in the list
      if (!currentPurposes.any((p) => p.id == event.purpose.id)) {
        currentPurposes.add(event.purpose);
      }
    } else {
      // Remove purpose if it exists in the list
      currentPurposes.removeWhere((p) => p.id == event.purpose.id);
    }

    emit(state.copyWith(selectedTravelPurposes: currentPurposes));
  }

  // --- Form Submission Handler ---
  Future<void> _onSubmitTravelForm(
    SubmitTravelFormEvent event,
    Emitter<TravelFormState> emit,
  ) async {
    // Check if form is valid before submission
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.failure,
          error: () => GeneralTravelFormError(),
        ),
      );
      return;
    }

    // Start submission process
    emit(state.copyWith(formSubmissionStatus: FormSubmissionStatus.submitting));

    try {
      if (state.selectedDepartureAirport == null ||
          state.selectedArrivalAirport == null ||
          state.selectedDateRange == null ||
          state.selectedNationality == null) {
        throw Exception('Missing required fields');
      }

      final travelInformation = TravelInformation(
        departureAirport: state.selectedDepartureAirport!,
        arrivalAirport: state.selectedArrivalAirport!,
        dateRange: state.selectedDateRange!,
        nationality: state.selectedNationality!,
        travelPurposes: state.selectedTravelPurposes,
      );

      // Simulate API call with delay
      final travelPlan = await _geminiRepository.generateTravelPlan(
        travelInformation,
      );

      final results = await Future.wait(
        [
          // Get city image from Unsplash
          _unsplashRepository.getCityView(
            cityName: travelPlan.city.name,
            countryName: travelPlan.city.country,
          ),
          // Get exchange rate from Currency API
          _currencyRepository.getExchangeRate(
            travelPlan.currency.departureCurrencyCode,
            travelPlan.currency.code,
          ),
        ],
      );

      final cityImage = results[0] as UnsplashPhoto?;
      final exchangeRate = results[1] as double?;

      final cityImageInBytes = await _imageRepository.downloadImageAsBase64(
        url: cityImage?.urls.full ?? '',
      );

      // Successful form submission
      emit(
        state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.success,
          travelPlan: () => travelPlan,
          cityImageInBytes: () => cityImageInBytes,
          exchangeRate: () => exchangeRate,
          error: () => null,
        ),
      );
    } catch (e) {
      // Handle submission error
      emit(
        state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.failure,
          error: e is FirebaseError ? () => ServerError() : () => GeneralTravelFormError(),
        ),
      );
    }
  }

  void _onRetryCountryService(
    RetryCountryServiceEvent event,
    Emitter<TravelFormState> emit,
  ) {
    // Reset the country service and reinitialize
    _countryService.reset();
    emit(state.copyWith(error: () => null));
    add(const TravelFormInitializeServices());
  }
}
