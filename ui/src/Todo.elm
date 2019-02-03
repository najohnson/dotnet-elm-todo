module Todo exposing (Todo, createTodo, defaultTodo, encodeTodo, getTodos, todoDecoder, updateTodo, deleteTodo)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder exposing (int, relative, string)


type alias Todo =
    { id : Int
    , name : String
    , isComplete : Bool
    }


defaultTodo : Todo
defaultTodo =
    { id = 0
    , name = ""
    , isComplete = False
    }


getTodos : String -> (Result Http.Error (List Todo) -> msg) -> Cmd msg
getTodos baseUrl msg =
    Http.get
        { url = baseUrl ++ relative [ "todo" ] []
        , expect = Http.expectJson msg (D.list todoDecoder)
        }


createTodo : String -> String -> (Result Http.Error Todo -> msg) -> Cmd msg
createTodo baseUrl todo msg =
    Http.post
        { url = baseUrl ++ relative [ "todo" ] []
        , body = Http.jsonBody <| encodeTodo { defaultTodo | name = todo }
        , expect = Http.expectJson msg todoDecoder
        }


updateTodo : String -> Todo -> (Result Http.Error Todo -> msg) -> Cmd msg
updateTodo baseUrl todo msg =
    Http.request
        { method = "PUT"
        , headers = []
        , url = baseUrl ++ relative [ "todo", String.fromInt todo.id ] []
        , body = Http.jsonBody <| encodeTodo todo
        , expect = Http.expectJson msg todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


deleteTodo : String -> Todo -> (Result Http.Error Todo -> msg) -> Cmd msg
deleteTodo baseUrl todo msg =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = baseUrl ++ relative [ "todo", String.fromInt todo.id ] []
        , body = Http.emptyBody
        , expect = Http.expectJson msg todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


todoDecoder : D.Decoder Todo
todoDecoder =
    D.map3 Todo
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "isComplete" D.bool)


encodeTodo : Todo -> E.Value
encodeTodo q =
    E.object
        [ ( "id", E.int q.id )
        , ( "name", E.string q.name )
        , ( "isComplete", E.bool q.isComplete )
        ]
