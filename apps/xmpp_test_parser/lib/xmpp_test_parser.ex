defmodule XmppTestParser do

  alias XmppTestParser.Structs.Stream, as: Stream
  alias XmppTestParser.Structs.Presence, as: Presence
  alias XmppTestParser.Structs.Message, as: Message
  alias XmppTestParser.Structs.IQ, as: IQ
  alias XmppTestParser.Structs.Query, as: Query
  alias XmppTestParser.Structs.Item, as: Item

  import SweetXml

  @moduledoc """
  Documentation for `XmppTestParser`.

  Module contains functions that receive binaries and return Xmpp-structs (see. stanzas)

  Module contains functions that receive Xmpp-structs and return corresponding xml-strings

  Available functions:
  + parse/1
  + to_xml/1
  + to_xml!/1
  """

  @doc ~S"""
  Parse the 'string_to_parse' and return a corresponding struct (message, iq, presence)

  ## Examples

    iex> XmppTestParser.parse(~s|<presence from="from" to="to" type="type" id="id"><status>status</status><show>show</show></presence>|)
    {:ok, %Presence{from: 'from', to: 'to', id: 'id', type: 'type', show: 'show', status: 'status'}}

    iex> XmppTestParser.parse(~s|<message from="from" to="to" type="type" id="id"><body>body</body></message>|)
    {:ok, %Message{from: 'from', to: 'to', id: 'id', type: 'type', body: 'body'}}

    iex> XmppTestParser.parse("random text")
    {:error, :invalid_message}

  """
  def parse(string_to_parse) do
    case string_to_parse do
      "<stream:stream>" -> {:ok, %Stream{start: true}}
      "</stream:stream>" -> {:ok, %Stream{stop: true}}
      <<"<presence", _rest ::bitstring>> -> parse_presence(string_to_parse)
      <<"<message", _rest ::bitstring>> -> parse_message(string_to_parse)
      <<"<iq", _rest ::bitstring>> -> parse_iq(string_to_parse)
      _ -> {:error, :invalid_message}
    end
  end

  @doc ~S"""
  Return the xml-representation of a valid Xmpp-Struct

  ## Examples

    iex> XmppTestParser.to_xml(%Presence{
    ...> from: 'from',
    ...> to: 'to',
    ...> type: 'type',
    ...> id: 'id',
    ...> status: 'status',
    ...> show: 'show'
    ...> })
    {:ok, "<presence from=\"from\" to=\"to\" type=\"type\" id=\"id\"><show>show</show><status>status</status></presence>"}

    iex> XmppTestParser.to_xml!(%Message{
    ...> from: "from",
    ...> to: "to",
    ...> body: "body"
    ...> })
    "<message from=\"from\" to=\"to\"><body>body</body></message>"

    iex> XmppTestParser.to_xml("some value")
    {:error, :invalid_stanza}

  """
  def to_xml(%Presence{} = presence) do
    {:ok, "<presence"
      |> Kernel.<>(if presence.from, do: ~s| from="#{presence.from}"|, else: "")
      |> Kernel.<>(if presence.to, do: ~s| to="#{presence.to}"|, else: "")
      |> Kernel.<>(if presence.type, do: ~s| type="#{presence.type}"|, else: "")
      |> Kernel.<>(if presence.id, do: ~s| id="#{presence.id}"|, else: "")
      |> Kernel.<>(">")
      |> Kernel.<>(if presence.show, do: "<show>#{presence.show}</show>", else: "")
      |> Kernel.<>(if presence.status, do: "<status>#{presence.status}</status>", else: "")
      |> Kernel.<>("</presence>")
    }
  end

  def to_xml(%Message{} = message) do
    {:ok, "<message"
      |> Kernel.<>(if message.from, do: ~s| from="#{message.from}"|, else: "")
      |> Kernel.<>(if message.to, do: ~s| to="#{message.to}"|, else: "")
      |> Kernel.<>(if message.type, do: ~s| type="#{message.type}"|, else: "")
      |> Kernel.<>(if message.id, do: ~s| id="#{message.id}"|, else: "")
      |> Kernel.<>(">")
      |> Kernel.<>(if message.body, do: "<body>#{message.body}</body>", else: "")
      |> Kernel.<>("</message>")
    }
  end

  def to_xml(%IQ{} = iq) do
    {:ok, "<iq"
      |> Kernel.<>(if iq.from, do: ~s| from="#{iq.from}"|, else: "")
      |> Kernel.<>(if iq.to, do: ~s| to="#{iq.to}"|, else: "")
      |> Kernel.<>(if iq.type, do: ~s| type="#{iq.type}"|, else: "")
      |> Kernel.<>(if iq.id, do: ~s| id="#{iq.id}"|, else: "")
      |> Kernel.<>(">")
      |> Kernel.<>(if iq.query, do: to_xml!(iq.query), else: "")
      |> Kernel.<>("</iq>")
    }
  end

  def to_xml(%Query{} = query) do
    {:ok, "<query"
      |> Kernel.<>(if query.xmlns, do: ~s| xmlns="#{query.xmlns}"|, else: "")
      |> Kernel.<>(">")
      |> Kernel.<>(Enum.map(query.items, &to_xml!/1) |> Enum.reduce("", fn(b, a) -> a<>b end))
      |> Kernel.<>("</query>")
    }
  end

  def to_xml(%Item{} = item) do
    {:ok, "<item"
      |> Kernel.<>(if item.jid, do: ~s| jid="#{item.jid}"|, else: "")
      |> Kernel.<>(if item.name, do: ~s| name="#{item.name}"|, else: "")
      |> Kernel.<>("/>")
    }
  end

  def to_xml(_) do
    {:error, :invalid_stanza}
  end

  def to_xml!(val) do
    {:ok, res} = to_xml(val)
    res
  end

  defp parse_presence(string_to_parse) do
    # repeated method call probably unnecessary
    # TODO: learn how to use the SweetXml-Module better
    # try ... rescue should normally not be used; it is used, because SweetXml relies on
    # the Erlang-module :xmerl
    try do
      {:ok, %Presence{
        from: xpath(string_to_parse, ~x"//presence/@from"),
        to: xpath(string_to_parse, ~x"//presence/@to"),
        type: xpath(string_to_parse, ~x"//presence/@type"),
        id: xpath(string_to_parse, ~x"//presence/@id"),
        show: xpath(string_to_parse, ~x"//presence/show/text()"),
        status: xpath(string_to_parse, ~x"//presence/status/text()")
      }}
    catch
      :exit, {:fatal, e} -> {:error, e}
      :exit, e -> {:error, e}
    end
  end

  defp parse_message(string_to_parse) do
    # repeated method call probably unnecessary
    # TODO: learn how to use the SweetXml-Module better
    # try ... rescue should normally not be used; it is used, because SweetXml relies on
    # the Erlang-module :xmerl
    try do
      {:ok, %Message{
        from: xpath(string_to_parse, ~x"//message/@from"),
        to: xpath(string_to_parse, ~x"//message/@to"),
        type: xpath(string_to_parse, ~x"//message/@type"),
        id: xpath(string_to_parse, ~x"//message/@id"),
        body: xpath(string_to_parse, ~x"//message/body/text()")
      }}
    catch
      :exit, {:fatal, e} -> {:error, e}
      :exit, e -> {:error, e}
    end
  end

  defp parse_iq(string_to_parse) do
    # repeated method call probably unnecessary
    # TODO: learn how to use the SweetXml-Module better
    # try ... rescue should normally not be used; it is used, because SweetXml relies on
    # the Erlang-module :xmerl
    try do
      {:ok, %IQ{
        from: xpath(string_to_parse, ~x"//iq/@from"),
        to: xpath(string_to_parse, ~x"//iq/@to"),
        type: xpath(string_to_parse, ~x"//iq/@type"),
        id: xpath(string_to_parse, ~x"//iq/@id"),
        query: %Query{
          # xmlns doesn't count as an attribute => problem
          # TODO solve the problem
          xmlns: xpath(string_to_parse, ~x"//iq/query/@xmlns"),
          # problem: count == 0
          items: case xpath(string_to_parse, ~x"count(//iq/query/item)") do
            0 -> []
            n -> for i <- 1..n do
              %Item{
                jid: xpath(string_to_parse, ~x"//iq/query/item[#{i}]/@jid"),
                name: xpath(string_to_parse, ~x"//iq/query/item[#{i}]/@name")
              }
            end
          end
        }
      }}
    catch
      :exit, {:fatal, e} -> {:error, e}
      :exit, e -> {:error, e}
    end
  end
end
