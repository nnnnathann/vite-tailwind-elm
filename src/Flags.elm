module Flags exposing
    ( Env
    , Error(..)
    , Flags
    , Mode(..)
    , errorToString
    , fromFlags
    , modeFromString
    , modeToString
    )

import Json.Decode as Dec


type alias Flags =
    Dec.Value


type Mode
    = Dev
    | Prod


type alias Env =
    { appUrl : String
    , mode : Mode
    , myApiUrl : String
    }


fromFlags : Flags -> Result Error Env
fromFlags v =
    Dec.decodeValue decodeEnv v
        |> Result.mapError Dec.errorToString
        |> Result.mapError GeneralError


decodeEnv : Dec.Decoder Env
decodeEnv =
    Dec.map3
        Env
        (Dec.field "appUrl" Dec.string)
        (Dec.field "mode" decodeMode)
        (Dec.field "myApiUrl" Dec.string)


modeToString : Mode -> String
modeToString mode =
    case mode of
        Dev ->
            "development"

        Prod ->
            "production"


modeFromString : String -> Maybe Mode
modeFromString str =
    case str of
        "development" ->
            Just Dev

        "production" ->
            Just Prod

        _ ->
            Nothing


decodeMode : Dec.Decoder Mode
decodeMode =
    let
        decodeModeString str =
            case modeFromString str of
                Just mode ->
                    Dec.succeed mode

                Nothing ->
                    Dec.fail ("Invalid mode: " ++ str)
    in
    Dec.string
        |> Dec.andThen decodeModeString


type Error
    = GeneralError String


errorToString : Error -> String
errorToString err =
    case err of
        GeneralError msg ->
            "There's a problem with an environment variable, when decoding the flags passed to Elm.Main.init({ flags: {...} }) I had trouble here: " ++ msg
