module Api exposing (..)

import Http
import Json.Decode as Dec
import Json.Encode as Enc


type ApiError
    = Retryable String
    | BadRequest String


getTheNumber : (Result Http.Error Int -> msg) -> Cmd msg
getTheNumber toMsg =
    Http.get
        { url = "/api/theNumber"
        , expect = Http.expectJson toMsg (apiCall decodeTheNumber)
        }



{-
   These things are common to all the API requests
-}


expectApiResult :
    { toMsg : Result ApiError a -> msg
    , decoder : Dec.Decoder a
    , url : String
    , method : String
    , body : Maybe Enc.Value
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
expectApiResult c =
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


expectApiJson : (Result ApiError a -> msg) -> Dec.Decoder a -> Http.Expect msg
expectApiJson toMsg decoder =
    Http.expectStringResponse toMsg (apiResponse decoder)


apiResponse : Dec.Decoder a -> Http.Response String -> Result ApiError a
apiResponse decoder response =
    case response of
        Http.NetworkError_ ->
            Err (Retryable "I had a problem connecting to the server")

        Http.BadUrl_ err ->
            Err (BadRequest ("I couldn't understand the URL" ++ err))

        Http.Timeout_ ->
            Err (Retryable "I had to wait too long before the server responded")

        Http.BadStatus_ meta body ->
            case errStatus meta.statusCode of
                StatusBadRequest ->
                    Debug.todo "StatusBadRequest"

                StatusInternalServerError ->
                    Debug.todo "branch 'StatusInternalServerError' not implemented"

                StatusUnknown ->
                    Debug.todo "branch 'StatusUnknown' not implemented"

        Http.GoodStatus_ _ _ ->
            Debug.todo "branch 'GoodStatus_ _ _' not implemented"


type ErrStatus
    = StatusBadRequest
    | StatusInternalServerError
    | StatusUnknown


errStatus : Int -> ErrStatus
errStatus status =
    if status < 500 then
        StatusBadRequest

    else if status == 500 then
        StatusInternalServerError

    else
        StatusUnknown
