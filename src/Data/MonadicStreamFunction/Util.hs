module Data.MonadicStreamFunction.Util where

-- External
import Control.Arrow
import Control.Category
import Control.Monad
import Control.Monad.Base
import Prelude hiding (id, (.))

-- Internal
import Data.MonadicStreamFunction.Core
import Data.VectorSpace
import Data.VectorSpace.Instances()

-- * Useful aliases
type MStream m a = MSF m () a
type MSink   m a = MSF m a ()


-- * Stateful accumulation

mappendS :: (Monoid n, Monad m) => MSF m n n
mappendS = mappendFrom mempty
{-# INLINE mappendS #-}

mappendFrom :: (Monoid n, Monad m) => n -> MSF m n n
mappendFrom n0 = MSF $ \n -> let acc = n0 `mappend` n
                              -- in acc `seq` return (acc, mappendFrom acc)
                              in return (acc, mappendFrom acc)

sumFrom :: (RModule v, Monad m) => v -> MSF m v v
sumFrom v = feedback v (arr (uncurry (^+^) >>> dup))
  where dup x = (x,x)

sumS :: (RModule v, Monad m) => MSF m v v
sumS = sumFrom zeroVector

count :: (Num n, Monad m) => MSF m a n
count = arr (const 1) >>> sumS

-- * Generating Signals

unfold :: Monad m => (a -> (b,a)) -> a -> MSF m () b
unfold f a = MSF $ \_ -> let (b,a') = f a in b `seq` return (b, unfold f a')
-- unfold f x = feedback x (arr (snd >>> f))

repeatedly :: Monad m => (a -> a) -> a -> MSF m () a
repeatedly f = repeatedly'
 where repeatedly' a = MSF $ \() -> let a' = f a in a' `seq` return (a, repeatedly' a')
-- repeatedly f x = feedback x (arr (f >>> \x -> (x,x)))

-- * Special cases of map

mapMSF :: Monad m => MSF m a b -> MSF m [a] [b]
mapMSF = MSF . consume
  where
    consume :: Monad m => MSF m a t -> [a] -> m ([t], MSF m [a] [t])
    consume sf []     = return ([], mapMSF sf)
    consume sf (a:as) = do
      (b, sf')   <- unMSF sf a
      (bs, sf'') <- consume sf' as
      b `seq` return (b:bs, sf'')

mapMaybeS :: Monad m => MSF m a b -> MSF m (Maybe a) (Maybe b)
mapMaybeS msf = go
  where
    go = MSF $ \maybeA -> case maybeA of
      Just a -> do
        (b, msf') <- unMSF msf a
        return (Just b, mapMaybeS msf')
      Nothing -> return (Nothing, go)



-- * Adding side effects
withSideEffect :: Monad m => (a -> m b) -> MSF m a a
withSideEffect method = (id &&& arrM method) >>> arr fst

withSideEffect_ :: Monad m => m b -> MSF m a a
withSideEffect_ method = withSideEffect $ const method

-- * Debugging

traceWith :: (Monad m, Show a) => (String -> m ()) -> String -> MSF m a a
traceWith method msg =
  withSideEffect (method . (msg ++) . show)

trace :: Show a => String -> MSF IO a a
trace = traceWith putStrLn

traceWhen :: (Monad m, Show a) => (a -> Bool) -> (String -> m ()) -> String -> MSF m a a
traceWhen cond method msg = withSideEffect $ \a ->
  when (cond a) $ method $ msg ++ show a

pauseOn :: Show a => (a -> Bool) -> String -> MSF IO a a
pauseOn cond = traceWhen cond $ \s -> print s >> getLine >> return ()


-- * Inserting monadic actions into MSFs

{-# DEPRECATED insert "Don't use this. arrM id instead" #-}
insert :: Monad m => MSF m (m a) a
insert = arrM id

arrM_ :: Monad m => m b -> MSF m a b
arrM_ = arrM . const

-- * Lifting from one monad into another


(^>>>) :: MonadBase m1 m2 => MSF m1 a b -> MSF m2 b c -> MSF m2 a c
sf1 ^>>> sf2 = liftMSFBase sf1 >>> sf2
{-# INLINE (^>>>) #-}

(>>>^) :: MonadBase m1 m2 => MSF m2 a b -> MSF m1 b c -> MSF m2 a c
sf1 >>>^ sf2 = sf1 >>> liftMSFBase sf2
{-# INLINE (>>>^) #-}

-- * Delays and signal overwriting

-- See also: 'iPre'

iPost :: Monad m => b -> MSF m a b -> MSF m a b
iPost b sf = MSF $ \_ -> return (b, sf)

next :: Monad m => b -> MSF m a b -> MSF m a b
next b sf = MSF $ \a -> do
  (b', sf') <- unMSF sf a
  return (b, next b' sf')
-- rather, once delay is tested:
-- next b sf = sf >>> delay b
