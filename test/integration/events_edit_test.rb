require 'test_helper'

class EventsEditTest < ActionDispatch::IntegrationTest
  def setup
    @event = events :empty
  end

  test "invalid edit with bad title" do
    patch event_path(@event), params: {
      event: {
        title: ''
      }
    }
    assert flash.empty?
    assert_template 'events/edit'
    assert_select 'div#error_explanation'
  end

  test "valid edits" do
    get edit_event_path(@event)
    assert_template 'events/edit'
    patch event_path(@event), params: {
      event: {
        participants_attributes: {
          '1' => { name: 'a',
                   email: 'a@example.com',
                   _destroy: 'false'
                 },
          '2' => { name: 'b',
                   email: 'b@example.com',
                   _destroy: 'false'
                 }
        }
      }
    }
    follow_redirect!
    assert_not flash.empty?
    assert_template 'events/show'
    participants = @event.participants.reload
    assert_equal 2, participants.size

    id1, id2 = participants.collect { |x| x.id }

    get edit_event_path(@event)
    patch event_path(@event), params: {
      event: {
        participants_attributes: {
          '0' => { name: 'a',
                   email: 'a@a.com',
                   _destroy: 'false',
                   id: id1
                 },
          '1' => { name: 'new b',
                   email: 'b@b.com',
                   _destroy: 'false',
                   id: id2
                 }
        }
      }
    }
    participants = @event.participants.reload
    assert_equal 2, participants.size
    assert_equal 'new b', participants[1].name

    get edit_event_path(@event)
    patch event_path(@event), params: {
      event: {
        participants_attributes: {
          '0' => { name: 'a',
                   email: 'a@a.com',
                   _destroy: '1',
                   id: id1
                 },
          '1' => { name: 'new b',
                   email: 'b@b.com',
                   _destroy: 'false',
                   id: id2
                 }
        }
      }
    }
    participants = @event.participants.reload
    assert_equal 1, participants.size
    assert_equal 'new b', participants[0].name
  end

  test "locale in edit page" do
    get edit_event_path(@event)
    assert_select 'select#event_locale > option[selected]', 'English'

    patch event_path(@event), params: {
      event: {
        locale: :fr
      }
    }

    get edit_event_path(@event)
    assert_select 'select#event_locale > option[selected]', 'Français'
  end

  test "edit amount" do
    patch event_path(@event), params: {
      event: {
        amount: '5€'
      }
    }

    get edit_event_path(@event)
    assert_match /5€/, response.body

    get event_path(@event)
    assert_match /5€/, response.body
  end
end
