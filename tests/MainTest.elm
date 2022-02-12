module MainTest exposing (spec)

import Expect
import Test exposing (Test, describe, test)


spec : Test
spec =
    describe "test suite" <|
        [ test "should test things" <|
            \_ ->
                Expect.equal 1 1
        ]
