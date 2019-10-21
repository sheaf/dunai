module FRPrefactoredSec4 where

-- External imports
-- TODO: Is this the right Writer?
import Control.Arrow                           (arr, (&&&), (>>>))
import Control.Monad.Trans.Reader              (ReaderT, asks)
import Data.MonadicStreamFunction.InternalCore (MSF (..))
import Data.MonadicStreamFunction
import Data.MonadicStreamFunction.Util         (count)

-- Internal imports
import FRPrefactoredSec3                       (Ball, Game)

type GameEnv = ReaderT GameSettings

data GameSettings = GameSettings
  { leftPlayerPos  :: Int
  , rightPlayerPos :: Int
  }

ballToRight :: Monad m => MSF (GameEnv m) () Ball
ballToRight = count >>> arrM (\n -> (n +) <$> asks leftPlayerPos)

hitRight :: Monad m => MSF (GameEnv m) Ball Bool
hitRight = arrM $ \i -> (i >=) <$> asks rightPlayerPos

testMSF :: Monad m => MSF (GameEnv m) () (Ball, Bool)
testMSF = ballToRight >>> (arr id &&& hitRight)

-- runReaderT (embed testMSF (repeat 5 ())) (GameSettings 0 3)
-- runReaderT (embed testMSF (repeat 5 ())) (GameSettings 0 2)
