// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_start_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeStartViewModelHash() =>
    r'375fbe8fe08a1c91d4c7a017249dec5f6e409413';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChallengeStartViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ChallengeStartState> {
  late final int challengeId;

  FutureOr<ChallengeStartState> build(
    int challengeId,
  );
}

/// See also [ChallengeStartViewModel].
@ProviderFor(ChallengeStartViewModel)
const challengeStartViewModelProvider = ChallengeStartViewModelFamily();

/// See also [ChallengeStartViewModel].
class ChallengeStartViewModelFamily
    extends Family<AsyncValue<ChallengeStartState>> {
  /// See also [ChallengeStartViewModel].
  const ChallengeStartViewModelFamily();

  /// See also [ChallengeStartViewModel].
  ChallengeStartViewModelProvider call(
    int challengeId,
  ) {
    return ChallengeStartViewModelProvider(
      challengeId,
    );
  }

  @override
  ChallengeStartViewModelProvider getProviderOverride(
    covariant ChallengeStartViewModelProvider provider,
  ) {
    return call(
      provider.challengeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeStartViewModelProvider';
}

/// See also [ChallengeStartViewModel].
class ChallengeStartViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChallengeStartViewModel,
        ChallengeStartState> {
  /// See also [ChallengeStartViewModel].
  ChallengeStartViewModelProvider(
    int challengeId,
  ) : this._internal(
          () => ChallengeStartViewModel()..challengeId = challengeId,
          from: challengeStartViewModelProvider,
          name: r'challengeStartViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$challengeStartViewModelHash,
          dependencies: ChallengeStartViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChallengeStartViewModelFamily._allTransitiveDependencies,
          challengeId: challengeId,
        );

  ChallengeStartViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final int challengeId;

  @override
  FutureOr<ChallengeStartState> runNotifierBuild(
    covariant ChallengeStartViewModel notifier,
  ) {
    return notifier.build(
      challengeId,
    );
  }

  @override
  Override overrideWith(ChallengeStartViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeStartViewModelProvider._internal(
        () => create()..challengeId = challengeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChallengeStartViewModel,
      ChallengeStartState> createElement() {
    return _ChallengeStartViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeStartViewModelProvider &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeStartViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ChallengeStartState> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeStartViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChallengeStartViewModel,
        ChallengeStartState> with ChallengeStartViewModelRef {
  _ChallengeStartViewModelProviderElement(super.provider);

  @override
  int get challengeId =>
      (origin as ChallengeStartViewModelProvider).challengeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
