module Main where

import Test.Framework (defaultMain, testGroup)

import qualified Snap.Types.Tests
import qualified Snap.Internal.Http.Types.Tests
import qualified Snap.Iteratee.Tests
import qualified Snap.Util.GZip.Tests


main :: IO ()
main = defaultMain tests
  where tests = [
                  testGroup "Snap.Internal.Http.Types.Tests"
                            Snap.Internal.Http.Types.Tests.tests
                , testGroup "Snap.Types.Tests"
                            Snap.Types.Tests.tests
                , testGroup "Snap.Iteratee.Tests"
                            Snap.Iteratee.Tests.tests
                , testGroup "Snap.Util.GZip.Tests"
                            Snap.Util.GZip.Tests.tests
                ]