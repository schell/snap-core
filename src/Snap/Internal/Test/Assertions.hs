{-# LANGUAGE OverloadedStrings #-}
module Snap.Internal.Test.Assertions where

------------------------------------------------------------------------------
import           Blaze.ByteString.Builder
import           Control.Monad (liftM)
import           Data.ByteString.Char8 (ByteString)
import           Data.Maybe (fromJust)
import           Data.Monoid (mconcat)
import qualified System.IO.Streams as Streams
import           Test.HUnit (Assertion, assertBool, assertEqual)
import           Text.Regex.Posix ((=~))

------------------------------------------------------------------------------
import           Snap.Internal.Http.Types

------------------------------------------------------------------------------
getResponseBody :: Response -> IO ByteString
getResponseBody rsp = do
    (os, grab) <- Streams.listOutputStream
    enum os
    liftM toBS grab

  where
    enum os = do
        os' <- rspBodyToEnum (rspBody rsp) os
        Streams.write Nothing os'

    toBS = toByteString . mconcat


------------------------------------------------------------------------------
-- | Given a Response, asserts that its HTTP status code is 200 (success).
assertSuccess :: Response -> Assertion
assertSuccess rsp = assertEqual message 200 status
  where
    message = "Expected success (200) but got (" ++ (show status) ++ ")"
    status  = rspStatus rsp


------------------------------------------------------------------------------
-- | Given a Response, asserts that its HTTP status code is 404 (Not Found).
assert404 :: Response -> Assertion
assert404 rsp = assertEqual message 404 status
  where
    message = "Expected Not Found (404) but got (" ++ (show status) ++ ")"
    status = rspStatus rsp


------------------------------------------------------------------------------
-- | Given a Response, asserts that its HTTP status code is between 300 and
-- 399 (a redirect), and that the Location header of the Response points to
-- the specified URI.
assertRedirectTo :: ByteString     -- ^ The Response should redirect to this
                                   -- URI
                 -> Response
                 -> Assertion
assertRedirectTo uri rsp = do
    assertRedirect rsp
    assertEqual message uri rspUri

  where
    rspUri = fromJust $ getHeader "Location" rsp
    message = "Expected redirect to " ++ show uri
              ++ " but got redirected to "
              ++ show rspUri ++ " instead"


------------------------------------------------------------------------------
-- | Given a Response, asserts that its HTTP status code is between 300 and
-- 399 (a redirect).
assertRedirect :: Response -> Assertion
assertRedirect rsp = assertBool message (300 <= status && status <= 399)
  where
    message = "Expected redirect but got status code ("
              ++ show status ++ ")"
    status  = rspStatus rsp


------------------------------------------------------------------------------
-- | Given a Response, asserts that its body matches the given regular
-- expression.
assertBodyContains :: ByteString  -- ^ Regexp that will match the body content
                   -> Response
                   -> Assertion
assertBodyContains match rsp = do
    body <- getResponseBody rsp
    assertBool message (body =~ match)
  where
    message = "Expected body to match regexp \"" ++ show match
              ++ "\", but didn't"
