part of dartz;

abstract class Either<L, R> extends TraversableOps<Either<L, dynamic>, R> with MonadOps<Either<L, dynamic>, R> {
  /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifLeft(L l), /*=C*/ ifRight(R r));
  R getOrElse(R dflt) => fold/*<R, R>*/((l) => dflt, (r) => r);
  Either leftMap(f(L l)) => fold((L l) => left(f(l)), (R r) => this);
  Option<R> toOption() => fold/*<Option<R>, Option<R>>*/((L l) => none(), (R r) => some(r));

  @override Either/*<L, R2>*/ pure/*<R2>*/(/*=R2*/ a) => right(a);
  @override Either/*<L, R2>*/ map/*<R2>*/(/*=R2*/ f(R r)) => fold((L l) => left(l), (R r) => right(f(r)));
  @override Either/*<L, R2>*/ bind/*<R2>*/(Either/*<L, R2>*/ f(R r)) => fold((L l) => left(l), (R r) => f(r));

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(R r)) => fold((L l) => gApplicative.pure(this), (R r) => gApplicative.map(f(r), right));

  @override String toString() => fold((l) => 'Left($l)', (r) => 'Right($r)');
}

class Left<L, R> extends Either<L, R> {
  final L _l;
  Left(this._l);
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifLeft(L l), /*=C*/ ifRight(R r)) => ifLeft(_l);
  @override bool operator ==(other) => other is Left && other._l == _l;
}

class Right<L, R> extends Either<L, R> {
  final R _r;
  Right(this._r);
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifLeft(L l), /*=C*/ ifRight(R r)) => ifRight(_r);
  @override bool operator ==(other) => other is Right && other._r == _r;
}


Either/*<L, R>*/ left/*<L, R>*/(/*=L*/ l) => new Left(l);
Either/*<L, R>*/ right/*<L, R>*/(/*=R*/ r) => new Right(r);
Either/*<dynamic, A>*/ catching/*<A>*/(Function0/*<A>*/ thunk) {
  try {
    return right(thunk());
  } catch(e) {
    return left(e);
  }
}

final Monad<Either> EitherM = new MonadOpsMonad<Either>(right);
final Applicative<Either> EitherA = EitherM;
final Functor<Either> EitherF = EitherM;

final Traversable<Either> EitherTr = new TraversableOpsTraversable<Either>();
final Foldable<Either> EitherFo = EitherTr;

class EitherTMonad<M> extends Monad<M> {
  Monad _stackedM;
  EitherTMonad(this._stackedM);
  Monad underlying() => EitherM;

  @override M pure(a) => _stackedM.pure(right(a)) as M;
  @override M bind(M mea, M f(_)) => _stackedM.bind(mea, (Either e) => e.fold((l) => _stackedM.pure(left(l)), f)) as M;
}

Monad eitherTMonad(Monad mmonad) => new EitherTMonad(mmonad);

