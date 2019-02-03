module Main exposing (main)

import Browser
import Css exposing (alignItems, center, displayFlex, flex, fontFamilies, height, int, padding, px, vw, width)
import ElmUIC.Button exposing (button, defaultButton)
import ElmUIC.Checkbox exposing (checkbox, defaultCheckbox)
import ElmUIC.Input exposing (defaultInput, input)
import ElmUIC.Modal exposing (defaultModal, modal)
import ElmUIC.Navbar exposing (defaultNavbar, item, navbar, separator)
import ElmUIC.Theme as Theme exposing (ColorSetting(..), Size(..), defaultTheme)
import Html
import Html.Styled exposing (Attribute, Html, div, text, toUnstyled)
import Html.Styled.Attributes exposing (css, placeholder, rows, value)
import Html.Styled.Events exposing (keyCode, on, onInput, stopPropagationOn)
import Http
import Json.Decode as Json
import Todo exposing (Todo, createTodo, deleteTodo, getTodos, updateTodo)


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)


onClick : msg -> Attribute msg
onClick msg =
    stopPropagationOn "click" (Json.map alwaysPreventDefault (Json.succeed msg))


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )


type Msg
    = NoOp
    | AddTodo
    | UpdateTodoContent String
    | ReceiveTodos (Result Http.Error (List Todo))
    | ReceiveTodo (Result Http.Error Todo)
    | UpdateTodo (Result Http.Error Todo)
    | CompleteTodo Todo
    | DeleteTodo Todo
    | ReceiveDeleteTodo (Result Http.Error Todo)


type alias Model =
    { todos : List Todo
    , newTodo : String
    , baseUrl : String
    , flash : String
    }


initialModel : String -> Model
initialModel baseUrl =
    { todos = []
    , newTodo = ""
    , baseUrl = baseUrl
    , flash = ""
    }


todoItem : Todo -> Html Msg
todoItem todo =
    div
        [ css
            [ displayFlex
            , alignItems center
            , width <| vw 100
            ]
        ]
        [ div [ css [ padding <| px 4, flex <| int 1 ] ]
            [ checkbox defaultTheme
                { defaultCheckbox
                    | checked = todo.isComplete
                }
                [ onClick <| CompleteTodo todo
                ]
                []
            ]
        , div [ css [ flex <| int 10 ] ] [ text todo.name ]
        , div [ css [ flex <| int 1 ] ]
            [ button
                defaultTheme
                { defaultButton | size = Small, kind = Danger }
                [ onClick <| DeleteTodo todo ]
                [ text "Delete" ]
            ]
        ]


view : Model -> Html Msg
view model =
    div
        [ css [ fontFamilies defaultTheme.font ] ]
        [ navbar defaultTheme
            { defaultNavbar | title = "Todo List" }
            [ css [ width <| vw 100 ] ]
            []
        , div
            [ css
                [ padding <| px 8
                ]
            ]
            [ input
                defaultTheme
                defaultInput
                [ placeholder "New Todo"
                , onInput UpdateTodoContent
                , onEnter AddTodo
                , value model.newTodo
                ]
                []
            , button
                defaultTheme
                { defaultButton | size = Small }
                [ onClick AddTodo ]
                [ text "Add Todo" ]
            ]
        , div
            [ css
                [ padding <| px 8
                ]
            ]
          <|
            List.map todoItem model.todos
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTodoContent content ->
            ( { model | newTodo = content }, Cmd.none )

        ReceiveTodos result ->
            case result of
                Ok todos ->
                    ( { model
                        | todos = todos
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | flash = "Failed getting todos!"
                      }
                    , Cmd.none
                    )

        UpdateTodo result ->
            case result of
                Ok todo ->
                    let
                        todos =
                            List.map
                                (\t ->
                                    if t.id == todo.id then
                                        todo

                                    else
                                        t
                                )
                                model.todos
                    in
                    ( { model
                        | todos = todos
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | flash = "Failed updating todo!"
                      }
                    , Cmd.none
                    )

        AddTodo ->
            ( model, createTodo model.baseUrl model.newTodo ReceiveTodo )

        CompleteTodo todo ->
            ( model, updateTodo model.baseUrl { todo | isComplete = not todo.isComplete } UpdateTodo )

        ReceiveTodo result ->
            case result of
                Ok todo ->
                    ( { model
                        | todos = todo :: model.todos
                        , flash = ""
                        , newTodo = ""
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | flash = "Failed creating todo!"
                      }
                    , Cmd.none
                    )

        DeleteTodo todo ->
            ( model, deleteTodo model.baseUrl todo ReceiveDeleteTodo )

        ReceiveDeleteTodo result ->
            case result of
                Ok todo ->
                    ( { model
                        | todos = List.filter (\t -> t.id /= todo.id) model.todos
                        , flash = ""
                        , newTodo = ""
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | flash = "Failed creating todo!"
                      }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )


init : String -> ( Model, Cmd Msg )
init baseUrl =
    ( initialModel baseUrl
    , getTodos baseUrl ReceiveTodos
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }
