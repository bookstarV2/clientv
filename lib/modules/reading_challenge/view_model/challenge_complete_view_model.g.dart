// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_complete_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeCompleteViewModelHash() =>
    r'452b73588814e01a6ff53f686c257b26ca4ab27a';

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

abstract class _$ChallengeCompleteViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ChallengeCompleteState> {
  late final int challengeId;

  FutureOr<ChallengeCompleteState> build(
    int challengeId,
  );
}

/// See also [ChallengeCompleteViewModel].
@ProviderFor(ChallengeCompleteViewModel)
const challengeCompleteViewModelProvider = ChallengeCompleteViewModelFamily();

/// See also [ChallengeCompleteViewModel].
class ChallengeCompleteViewModelFamily
    extends Family<AsyncValue<ChallengeCompleteState>> {
  /// See also [ChallengeCompleteViewModel].
  const ChallengeCompleteViewModelFamily();

  /// See also [ChallengeCompleteViewModel].
  ChallengeCompleteViewModelProvider call(
    int challengeId,
  ) {
    return ChallengeCompleteViewModelProvider(
      challengeId,
    );
  }

  @override
  ChallengeCompleteViewModelProvider getProviderOverride(
    covariant ChallengeCompleteViewModelProvider provider,
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
  String? get name => r'challengeCompleteViewModelProvider';
}

/// See also [ChallengeCompleteViewModel].
class ChallengeCompleteViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChallengeCompleteViewModel,
        ChallengeCompleteState> {
  /// See also [ChallengeCompleteViewModel].
  ChallengeCompleteViewModelProvider(
    int challengeId,
  ) : this._internal(
          () => ChallengeCompleteViewModel()..challengeId = challengeId,
          from: challengeCompleteViewModelProvider,
          name: r'challengeCompleteViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$challengeCompleteViewModelHash,
          dependencies: ChallengeCompleteViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChallengeCompleteViewModelFamily._allTransitiveDependencies,
          challengeId: challengeId,
        );

  ChallengeCompleteViewModelProvider._internal(
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
  FutureOr<ChallengeCompleteState> runNotifierBuild(
    covariant ChallengeCompleteViewModel notifier,
  ) {
    return notifier.build(
      challengeId,
    );
  }

  @override
  Override overrideWith(ChallengeCompleteViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeCompleteViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChallengeCompleteViewModel,
      ChallengeCompleteState> createElement() {
    return _ChallengeCompleteViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeCompleteViewModelProvider &&
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
mixin ChallengeCompleteViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ChallengeCompleteState> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeCompleteViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChallengeCompleteViewModel,
        ChallengeCompleteState> with ChallengeCompleteViewModelRef {
  _ChallengeCompleteViewModelProviderElement(super.provider);

  @override
  int get challengeId =>
      (origin as ChallengeCompleteViewModelProvider).challengeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
