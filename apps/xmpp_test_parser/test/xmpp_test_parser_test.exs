defmodule XmppTestParserTest do

  use ExUnit.Case, async: true

  alias XmppTestParser.Structs.Stream, as: Stream
  alias XmppTestParser.Structs.Presence, as: Presence
  alias XmppTestParser.Structs.Message, as: Message
  alias XmppTestParser.Structs.IQ, as: IQ
  alias XmppTestParser.Structs.Query, as: Query
  alias XmppTestParser.Structs.Item, as: Item

  doctest XmppTestParser

  test "parses strings" do
    assert {:error, :invalid_message} = XmppTestParser.parse("some text")
    assert {:ok, %Stream{start: true, stop: false}} == XmppTestParser.parse("<stream:stream>")
    assert {:ok, %Stream{start: false, stop: true}} == XmppTestParser.parse("</stream:stream>")
  end

  test "parses presence-stanzas" do
    # well formed and valid
    xml = ~s|<presence type="type" from="from" to="to" id="id">
                <show>show</show>
                <status>status</status>
              </presence>|
    assert {:ok, %Presence{
      type: 'type',
      from: 'from',
      to: 'to',
      id: 'id',
      status: 'status',
      show: 'show'
    }} == XmppTestParser.parse(xml)

    # unknown attributes and nodes are ignored
    xml = ~s|<presence type="type" from123="from" to="to" id="id">
                <show123>show</show123>
                <status>status</status>
              </presence>|
    assert {:ok, %Presence{
      type: 'type',
      from: nil,
      to: 'to',
      id: 'id',
      status: 'status',
      show: nil
    }} == XmppTestParser.parse(xml)
  end

  test "message-stanzas" do
    # well formed and valid
    xml = ~s|<message type="type" from="from" to="to" id="id">
                <body>body</body>
              </message>|
    assert {:ok, %Message{
      type: 'type',
      from: 'from',
      to: 'to',
      id: 'id',
      body: 'body'
    }} == XmppTestParser.parse(xml)
  end

  test "iq-stanzas" do
    # multiple items (query-results)
    xml = ~s|<iq type="type" from="from" to="to" id="id">
                <query xmlns="namespace">
                  <item jid="jid1" name="name1"/>
                  <item jid="jid2" name="name2"/>
                </query>
              </iq>|
    assert {:ok, %IQ{
      type: 'type',
      from: 'from',
      to: 'to',
      id: 'id',
      query: %Query{
        xmlns: :namespace,
        items: [
          %Item{jid: "jid1", name: "name1"},
          %Item{jid: "jid2", name: "name2"}
        ]
      }
    }} == XmppTestParser.parse(xml)

    # one item
    xml = ~s|<iq type="type" from="from" to="to" id="id">
                <query xmlns="namespace">
                  <item jid="jid1" name="name1"/>
                </query>
              </iq>|
    assert {:ok, %IQ{
      type: 'type',
      from: 'from',
      to: 'to',
      id: 'id',
      query: %Query{
        items: [
          %Item{jid: "jid1", name: "name1"}
        ],
        xmlns: :namespace,
      }
    }} == XmppTestParser.parse(xml)

    # no items
    xml = ~s|<iq type="type" from="from" to="to" id="id">
                <query xmlns="namespace">
                </query>
              </iq>|
    assert {:ok, %IQ{
      type: 'type',
      from: 'from',
      to: 'to',
      id: 'id',
      query: %Query{
        xmlns: :namespace,
        items: []
      }
    }} == XmppTestParser.parse(xml)
  end

  test "invalid xml" do
    xml = ~s|<presence><show>away</show>|
    assert {:error, _} = XmppTestParser.parse(xml)

    xml = ~s|<presence><show>away</show></presence|
    assert {:error, _} = XmppTestParser.parse(xml)

    xml = ~s|<presence><show>away</presence></show>|
    assert {:error, _} = XmppTestParser.parse(xml)
  end

  test "presence to xml" do
    presence = %Presence{
      from: "from",
      to: "to",
      type: "type",
      id: "id",
      status: "status",
      show: "show"
    }
    assert XmppTestParser.to_xml(presence) == {:ok,
      ~s|<presence from="from" to="to" type="type" id="id"><show>show</show><status>status</status></presence>|
    }

    presence = %Presence{
      from: "from",
      to: "to",
      id: "id",
      show: "show"
    }
    assert XmppTestParser.to_xml(presence) == {:ok,
      ~s|<presence from="from" to="to" id="id"><show>show</show></presence>|
    }
  end

  test "message to xml" do
    message = %Message{
      from: "from",
      to: "to",
      type: "type",
      id: "id",
      body: "body"
    }
    assert XmppTestParser.to_xml(message) == {:ok,
      ~s|<message from="from" to="to" type="type" id="id"><body>body</body></message>|
    }

    message = %Message{
      from: "from",
      to: "to"
    }
    assert XmppTestParser.to_xml(message) == {:ok,
      ~s|<message from="from" to="to"></message>|
    }
  end

  test "iq to xml" do
    iq = %IQ{
      from: "from",
      to: "to",
      type: "type",
      id: "id",
      query: %Query{
        xmlns: "namespace",
        items: [
          %Item{jid: "jid1", name: "name1"},
          %Item{jid: "jid2", name: "name2"}
        ]
      }
    }
    assert XmppTestParser.to_xml(iq) == {:ok,
      ~s|<iq from="from" to="to" type="type" id="id"><query xmlns="namespace"><item jid="jid1" name="name1"/><item jid="jid2" name="name2"/></query></iq>|
    }

    iq = %IQ{
      from: "from",
      to: "to",
      query: %Query{
        items: [
          %Item{jid: "jid1", name: "name1"}
        ]
      }
    }
    assert XmppTestParser.to_xml(iq) == {:ok,
      ~s|<iq from="from" to="to"><query><item jid="jid1" name="name1"/></query></iq>|
    }

    iq = %IQ{
      from: "from",
      to: "to",
      query: %Query{
        items: []
      }
    }
    assert XmppTestParser.to_xml(iq) == {:ok,
      ~s|<iq from="from" to="to"><query></query></iq>|
    }
  end
end
