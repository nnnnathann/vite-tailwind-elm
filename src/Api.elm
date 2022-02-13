module Api exposing
    ( Error(..)
    , Request
    , ResponseStatus(..)
    , State(..)
    , errorToHtml
    , errorToString
    , expectApiJson
    , getTheNumber
    , viewError
    , viewWithLoader
    )

import Html exposing (Html)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Dec
import Json.Encode as Enc



{- Read the number from the api -}


getTheNumber : { apiUrl : String, toMsg : Result Error Int -> msg } -> Cmd msg
getTheNumber { apiUrl, toMsg } =
    let
        request : Request Int msg
        request =
            { toMsg = toMsg
            , decoder = Dec.field "theNumber" Dec.int
            , url = apiUrl ++ "/theNumber"
            , method = "GET"
            , body = Nothing
            , timeout = Just 1000.0
            , tracker = Nothing
            }
    in
    doRequest request



{- These things are common to all the API requests -}


type Error
    = Retryable String
    | BadRequest (List String)
    | BadFormat (List String)
    | ServerProblem (List String)


errorToHtml : Error -> Html msg
errorToHtml err =
    let
        titledList title msgs =
            Html.div [ class "text-left overflow-x-scroll" ]
                (List.concat
                    [ [ Html.h1 [ class "font-bold border-b-2 border-dashed border-slate-600 pb-4 mb-4" ] [ Html.text title ] ]
                    , msgs
                        |> List.map
                            (\msg ->
                                Html.div [ class "whitespace-nowrap" ] [ Html.text msg ]
                            )
                    ]
                )
    in
    case err of
        Retryable _ ->
            Html.text (errorToString err)

        BadRequest msgs ->
            titledList "Bad Request (maybe try again with different entry?)" msgs

        BadFormat msgs ->
            titledList "Bad Format (on our end)" msgs

        ServerProblem msgs ->
            titledList "Server-Side Problem (on our end)" msgs


errorToString : Error -> String
errorToString err =
    case err of
        Retryable msg ->
            msg ++ ", this problem might be temporary! Please try again."

        BadRequest msgs ->
            "Bad request: " ++ String.join ", " msgs

        BadFormat msgs ->
            "Bad format: " ++ String.join ", " msgs

        ServerProblem msgs ->
            "Server problem: " ++ String.join ", " msgs


type alias Request a msg =
    { toMsg : Result Error a -> msg
    , decoder : Dec.Decoder a
    , url : String
    , method : String
    , body : Maybe Enc.Value
    , timeout : Maybe Float
    , tracker : Maybe String
    }


doRequest : Request a msg -> Cmd msg
doRequest c =
    Http.request
        { url = c.url
        , expect = expectApiJson c.toMsg c.decoder
        , headers = [ Http.header "Content-Type" "application/json" ]
        , method = c.method
        , body =
            c.body
                |> Maybe.map Http.jsonBody
                |> Maybe.withDefault Http.emptyBody
        , timeout = c.timeout
        , tracker = c.tracker
        }


expectApiJson : (Result Error a -> msg) -> Dec.Decoder a -> Http.Expect msg
expectApiJson toMsg decoder =
    Http.expectStringResponse toMsg (apiResponse decoder)


apiResponse : Dec.Decoder a -> Http.Response String -> Result Error a
apiResponse decoder response =
    case response of
        Http.NetworkError_ ->
            Err (Retryable "I had a problem connecting to the server")

        Http.BadUrl_ err ->
            Err (BadRequest [ "I couldn't understand the URL" ++ err ])

        Http.Timeout_ ->
            Err (Retryable "I had to wait too long before the server responded")

        Http.BadStatus_ meta body ->
            readApiResponse decoder meta body

        Http.GoodStatus_ meta body ->
            readApiResponse decoder meta body


readApiResponse : Dec.Decoder a -> Http.Metadata -> String -> Result Error a
readApiResponse decoder meta body =
    let
        errorBody : (List String -> Error) -> String -> Result Error a
        errorBody toErr b =
            Dec.decodeString decodeApiErrorBody b
                |> Result.mapError formatError
                |> Result.map toErr
                |> Result.andThen Err
    in
    case statusFromInt meta.statusCode of
        StatusOk ->
            Dec.decodeString decoder body
                |> Result.mapError formatError

        StatusBadRequest _ ->
            errorBody BadRequest body

        StatusServerError _ ->
            errorBody ServerProblem body

        StatusUnknown _ ->
            errorBody ServerProblem body


formatError : Dec.Error -> Error
formatError =
    Dec.errorToString >> List.singleton >> BadFormat


decodeApiErrorBody : Dec.Decoder (List String)
decodeApiErrorBody =
    Dec.list (Dec.field "message" Dec.string)
        |> Dec.field "errors"



{-
   API Status Codes
-}


type ResponseStatus
    = StatusOk
    | StatusBadRequest Int
    | StatusServerError Int
    | StatusUnknown Int


statusFromInt : Int -> ResponseStatus
statusFromInt status =
    if status < 300 then
        StatusOk

    else if status > 399 && status < 500 then
        StatusBadRequest status

    else if status == 500 then
        StatusServerError status

    else
        StatusUnknown status



{- Management for values loaded from the API -}


type State a
    = Idle
    | Loading
    | Loaded (Result Error a)


viewWithLoader : (a -> Html msg) -> State a -> Html msg
viewWithLoader view state =
    case state of
        Idle ->
            Html.span [] []

        Loading ->
            Html.text "Loading..."

        Loaded (Err err) ->
            viewError err

        Loaded (Ok a) ->
            view a


viewError : Error -> Html msg
viewError err =
    Html.div [ class "p-8 fixed left-0 top-0 w-full" ]
        [ Html.div [ class "text-red-300 bg-slate-800 p-8 rounded drop-shadow-2xl" ] [ errorToHtml err ]
        ]
