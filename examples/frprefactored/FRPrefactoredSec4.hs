module FRPrefactoredSec4 where

-- External imports
-- TODO: Is this the right Writer?
import Control.Arrow                           (arr, (&&&), (>>>))
import Control.Monad.Base                      (MonadBase, liftBase)
import Control.Monad.Trans.Reader              (ReaderT, asks)
import Data.MonadicStreamFunction.Core         (liftBaseM)
import Data.MonadicStreamFunction.InternalCore (MSF (..))
import Data.MonadicStreamFunction.Util         (count)

-- Internal imports
import FRPrefactoredSec3                       (Ball, Game)

type GameEnv = ReaderT GameSettings

data GameSettings = GameSettings
  { leftPlayerPos  :: Int
  , rightPlayerPos :: Int
  }

ballToRight :: Monad m => MSF (GameEnv m) () Ball
ballToRight = count >>> liftS (\n -> (n +) <$> asks leftPlayerPos)

hitRight :: Monad m => MSF (GameEnv m) Ball Bool
hitRight = liftS $ \i -> (i >=) <$> asks rightPlayerPos

testMSF = ballToRight >>> (arr id &&& hitRight)

-- In dunai-core it is called liftS, in dunai it is called liftBaseM.
liftS :: (Monad m2, MonadBase m1 m2) => (a -> m1 b) -> MSF m2 a b
liftS = liftBaseM

-- runReaderT (embed testMSF (repeat 5 ())) (GameSettings 0 3)
-- runReaderT (embed testMSF (repeat 5 ())) (GameSettings 0 2)
