port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput, onSubmit)



-- JavaScript usage: app.ports.websocketIn.send(response);


port websocketIn : (String -> msg) -> Sub msg



-- JavaScript usage: app.ports.websocketOut.subscribe(handler);


port websocketOut : String -> Cmd msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



{- MODEL -}


type alias Model =
    { responses : List String
    , input : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { responses = []
      , input = ""
      }
    , Cmd.none
    )



{- UPDATE -}


type Msg
    = Change String
    | Submit String
    | WebsocketIn String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change input ->
            ( { model | input = input }
            , Cmd.none
            )

        Submit value ->
            ( model
            , websocketOut value
            )

        WebsocketIn value ->
            ( { model | responses = value :: model.responses }
            , Cmd.none
            )



{- SUBSCRIPTIONS -}


subscriptions : Model -> Sub Msg
subscriptions _ =
    websocketIn WebsocketIn



{- VIEW -}


li : String -> Html Msg
li string =
    Html.li [] [ Html.text string ]


view : Model -> Html Msg
view model =
    Html.div []
        --[ Html.form [onSubmit (WebsocketIn model.input)] -- Short circuit to test without ports
        [ Html.form [ onSubmit (Submit model.input) ]
            [ Html.input [ placeholder "Enter some text.", value model.input, onInput Change ] []
            , model.responses |> List.map li |> Html.ol []
            ]
        ]
