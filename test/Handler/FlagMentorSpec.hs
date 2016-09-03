module Handler.FlagMentorSpec (spec) where

import TestImport

import Database.Persist.Sql (toSqlKey)
import Utils.Flag

spec :: Spec
spec = withApp $ do

    describe "getFlagMentorR" $ do
        it "asserts flag link doesn't show to own user" $ do
            userEntity <- createUser "foo"
            authenticateAs userEntity

            get ProfileR
            htmlCount ".flag-wrapper" 0

        it "asserts flag link doesn't show to anonymous users" $ do
            userEntity <- createUser "foo"
            let (Entity _ user) = userEntity

            get $ UserR (userIdent user)
            htmlCount ".flag-wrapper" 0

        it "asserts flag link is showen to autheenticated users" $ do
            userEntity <- createUser "foo"
            let (Entity _ user) = userEntity

            userEntity' <- createUser "bar"
            authenticateAs userEntity'

            get $ UserR (userIdent user)
            htmlCount ".flag-wrapper" 1

        it "asserts token value is reproducible" $ do
            let csrf = Just "1234" :: Maybe Text
            let entityKey = toSqlKey 1 :: UserId
            let token = getFlagToken csrf entityKey Flag

            let expected = "58fbe9c10ce55a240b0b94b5bd619f18" :: Text
            assertEq "Token is valid" expected token
