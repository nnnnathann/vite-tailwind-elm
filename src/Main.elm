module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Flags
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (onClick)
import Url


appTitle : String
appTitle =
    "New Application"


type AppError
    = FlagsError Flags.Error


main : Program Flags.Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , env : Result Flags.Error Flags.Env
    , theNumber : Api.State Int
    }


init : Flags.Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        env =
            Flags.fromFlags flags

        initCmd =
            env
                |> Result.map (\{ myApiUrl } -> Api.getTheNumber { apiUrl = myApiUrl, toMsg = GotTheNumber })
                |> Result.withDefault Cmd.none

        newModel : Model
        newModel =
            { key = key
            , url = url
            , env = env
            , theNumber =
                if initCmd == Cmd.none then
                    Api.Idle

                else
                    Api.Loading
            }
    in
    ( newModel, initCmd )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | AccessDashboardClicked
    | GotTheNumber (Result Api.Error Int)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        AccessDashboardClicked ->
            ( model, Nav.pushUrl model.key "dashboard" )

        GotTheNumber num ->
            ( { model | theNumber = Api.Loaded num }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = appTitle
    , body =
        [ div [ class "h-screen flex items-center justify-center bg-slate-200" ]
            [ div [ class "bg-white p-8 shadow rounded text-center" ]
                [ model.env
                    |> Result.mapError (FlagsError >> viewError)
                    |> Result.map (viewMain model)
                    |> unionResult
                , div [ class "text-purple-500" ]
                    [ Api.viewWithLoader
                        (\i ->
                            Html.text ("Server SAYS: " ++ String.fromInt i)
                        )
                        model.theNumber
                    ]
                ]
            ]
        ]
    }


viewMain : Model -> Flags.Env -> Html.Html Msg
viewMain model env =
    div []
        [ h1 [ class "mb-4" ] [ text appTitle ]
        , p [ class "text-left" ] [ text ("Welcome to the path " ++ model.url.path) ]
        , p [ class "text-left" ] [ text ("Running in " ++ Flags.modeToString env.mode ++ " mode") ]
        , p [ class "text-left" ]
            [ viewInfoLink "https://vitejs.dev" "Learn more about Vite"
            , viewInfoLink "https://tailwindcss.com" "Learn more about Tailwind"
            , viewInfoLink "https://elm-lang.org/" "Learn more about Elm"
            ]
        , div [ class "p-2" ]
            [ button [ onClick AccessDashboardClicked ] [ text "Access Dashboard" ] ]
        ]


viewInfoLink : String -> String -> Html.Html msg
viewInfoLink link label =
    a [ target "_blank", class "underline block", href link ] [ text label ]


viewError : AppError -> Html.Html msg
viewError err =
    let
        errMessage msg =
            div [ class "border-l-4 p-2 border-red-400" ] [ text msg ]
    in
    case err of
        FlagsError envErr ->
            Flags.errorToString envErr
                |> errMessage


unionResult : Result a a -> a
unionResult result =
    case result of
        Ok a ->
            a

        Err a ->
            a
