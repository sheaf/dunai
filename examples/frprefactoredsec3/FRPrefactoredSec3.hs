-- Examples from Functional Reactive Programming, Refactored: Section 3
module FRPrefactoredSec3
 ( embed
 , second
 ) where

import Control.Arrow                           (arr, second, (&&&), (>>>))
import Control.Monad.Base                      (MonadBase)
import Data.MonadicStreamFunction.Core         (liftBaseM)
import Data.MonadicStreamFunction.InternalCore (MSF (..), embed)

-- In dunai-core it is called liftS, in dunai it is called liftBaseM.
liftS :: (Monad m2, MonadBase m1 m2) => (a -> m1 b) -> MSF m2 a b
liftS = liftBaseM

add :: (Num n, Monad m) => n -> MSF m n n
add n0 = arr (\n -> n + n0)

testSerial :: MSF IO () ()
testSerial = liftS (\() -> getLine)
             >>> (arr id &&& arr reverse) >>> liftS print
