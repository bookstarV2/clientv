// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_quiz_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeQuizViewModelHash() =>
    r'0ce8c97ab5997a982dfa8078146b2e6922e42051';

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

abstract class _$ChallengeQuizViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ChallengeQuizState> {
  late final int chapterId;

  FutureOr<ChallengeQuizState> build(
    int chapterId,
  );
}

/// See also [ChallengeQuizViewModel].
@ProviderFor(ChallengeQuizViewModel)
const challengeQuizViewModelProvider = ChallengeQuizViewModelFamily();

/// See also [ChallengeQuizViewModel].
class ChallengeQuizViewModelFamily
    extends Family<AsyncValue<ChallengeQuizState>> {
  /// See also [ChallengeQuizViewModel].
  const ChallengeQuizViewModelFamily();

  /// See also [ChallengeQuizViewModel].
  ChallengeQuizViewModelProvider call(
    int chapterId,
  ) {
    return ChallengeQuizViewModelProvider(
      chapterId,
    );
  }

  @override
  ChallengeQuizViewModelProvider getProviderOverride(
    covariant ChallengeQuizViewModelProvider provider,
  ) {
    return call(
      provider.chapterId,
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
  String? get name => r'challengeQuizViewModelProvider';
}

/// See also [ChallengeQuizViewModel].
class ChallengeQuizViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChallengeQuizViewModel,
        ChallengeQuizState> {
  /// See also [ChallengeQuizViewModel].
  ChallengeQuizViewModelProvider(
    int chapterId,
  ) : this._internal(
          () => ChallengeQuizViewModel()..chapterId = chapterId,
          from: challengeQuizViewModelProvider,
          name: r'challengeQuizViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$challengeQuizViewModelHash,
          dependencies: ChallengeQuizViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChallengeQuizViewModelFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  ChallengeQuizViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final int chapterId;

  @override
  FutureOr<ChallengeQuizState> runNotifierBuild(
    covariant ChallengeQuizViewModel notifier,
  ) {
    return notifier.build(
      chapterId,
    );
  }

  @override
  Override overrideWith(ChallengeQuizViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeQuizViewModelProvider._internal(
        () => create()..chapterId = chapterId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChallengeQuizViewModel,
      ChallengeQuizState> createElement() {
    return _ChallengeQuizViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeQuizViewModelProvider &&
        other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeQuizViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ChallengeQuizState> {
  /// The parameter `chapterId` of this provider.
  int get chapterId;
}

class _ChallengeQuizViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChallengeQuizViewModel,
        ChallengeQuizState> with ChallengeQuizViewModelRef {
  _ChallengeQuizViewModelProviderElement(super.provider);

  @override
  int get chapterId => (origin as ChallengeQuizViewModelProvider).chapterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
