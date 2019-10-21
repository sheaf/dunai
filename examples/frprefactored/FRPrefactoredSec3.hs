-- Examples from Functional Reactive Programming, Refactored: Section 3
module FRPrefactoredSec3
 ( embed
 , second
 , Game
 , Ball
 ) where

import Control.Arrow                           (arr, second, (&&&), (>>>))
import Control.Monad.Base                      (MonadBase)
import Data.MonadicStreamFunction.Core
import Data.MonadicStreamFunction.InternalCore (MSF (..), embed)
import Data.MonadicStreamFunction.Util         (count)


add :: (Num n, Monad m) => n -> MSF m n n
add n0 = arr (\n -> n + n0)

testSerial :: MSF IO () ()
testSerial = arrM (\() -> getLine)
             >>> (arr id &&& arr reverse) >>> arrM print

type Game = Ball
type Ball = Int

rightPlayerPos = 5
leftPlayerPos  = 0

ballToRight :: Monad m => MSF m () Ball
ballToRight = count >>> arr (\n -> leftPlayerPos + n)

ballToLeft :: Monad m => MSF m () Ball
ballToLeft = count >>> arr (\n -> rightPlayerPos - n)

hitRight :: Monad m => MSF m Ball Bool
hitRight = arr (>= rightPlayerPos)

hitLeft :: Monad m => MSF m Ball Bool
hitLeft = arr (<= leftPlayerPos)
