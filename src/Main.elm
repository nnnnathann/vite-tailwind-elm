module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Env
import Html exposing (..)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (onClick)
import Http
import Url


appTitle : String
appTitle =
    "New Application"


type AppError
    = EnvError Env.Error


main : Program Env.Flags Model Msg
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
    , env : Result Env.Error Env.Env
    }


init : Env.Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        env =
            Env.fromFlags flags

        newModel : Model
        newModel =
            { key = key
            , url = url
            , env = env
            }
    in
    ( newModel, Http.get { url = "http://google.com", expect = Http.expectWhatever (\_ -> NoOp) } )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | AccessDashboardClicked
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
                    |> Result.mapError (EnvError >> viewError)
                    |> Result.map (viewMain model)
                    |> unionResult
                ]
            ]
        ]
    }


viewMain : Model -> Env.Env -> Html.Html Msg
viewMain model env =
    div []
        [ h1 [ class "mb-4" ] [ text appTitle ]
        , p [ class "text-left" ] [ text ("Welcome to the path " ++ model.url.path) ]
        , p [ class "text-left" ] [ text ("Running in " ++ Env.modeToString env.mode ++ " mode") ]
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
        EnvError envErr ->
            Env.errorToString envErr
                |> errMessage


unionResult : Result a a -> a
unionResult result =
    case result of
        Ok a ->
            a

        Err a ->
            a
