#!/bin/env ruby
#frozen_string_literal: true

require 'date'

rooms = [
  {
    id: 1,
    name: '101'
  }, {
    id: 2,
    name: '102'
  }, {
    id: 3,
    name: '103'
  }
]

bookings = [
  {
    checkin: '2017-10-1',
    checkout: '2017-10-3',
    room_id: 2,
    locked: true,
    id: 1
  }, {
    checkin: '2017-10-1',
    checkout: '2017-10-4',
    id: 2
  }, {
    checkin: '2017-10-3',
    checkout: '2017-10-6',
    id: 3
  }, {
    checkin: '2017-10-3',
    checkout: '2017-10-8',
    id: 4
  }, {
    checkin: '2017-10-4',
    checkout: '2017-10-8',
    room_id: 1,
    locked: true,
    id: 5
  }, {
    checkin: '2017-10-8',
    checkout: '2017-10-12',
    id: 6
  }, {
    checkin: '2017-10-9',
    checkout: '2017-10-20',
    id: 7
  }, {
    checkin: '2017-10-15',
    checkout: '2017-10-20',
    id: 8
  }, {
    checkin: '2017-10-21',
    checkout: '2017-10-30',
    id: 9
  }
]

def format_bookings(bookings)
  bookings_with_date = bookings.map do |booking|
    booking.merge(
      checkin_date: (Date.parse(booking[:checkin]) rescue nil),
      checkout_date: (Date.parse(booking[:checkout]) rescue nil)
    )
  end

  bookings_sort_checkin = bookings_with_date.sort_by {|booking| booking[:checkin_date] ? booking[:checkin_date].to_time.to_i : Date::Infinity.new}

  bookings_sort_checkin.inject({}) do |result, booking|
    result[booking[:id]] = booking
    result
  end
end

def assign_rooms(bookings, rooms)
  formatted_rooms = rooms.inject({}) do |result, room|
    result[room[:id]] = room.merge(bookings: [])
    result
  end

  formatted_bookings = format_bookings(bookings)

  get_last_booking_of_room = ->(room) { formatted_bookings[room[:bookings].last] }

  formatted_bookings.each do |booking_id, booking|
    begin
      raise 'checkin or checkout is invalid' if booking[:checkin_date].nil? || booking[:checkout_date].nil?

      booking_room = formatted_rooms[booking[:room_id]] if booking[:locked]
      last_booking = get_last_booking_of_room.call(booking_room) if booking_room

      if booking_room && (last_booking.nil? || booking[:checkin_date] >= last_booking[:checkout_date])
        booking_room[:bookings].push(booking_id)
      else
        formatted_rooms.each do |_, room|
          last_booking = get_last_booking_of_room.call(room)

          if last_booking.nil? || booking[:checkin_date] >= last_booking[:checkout_date]
            room[:bookings].push(booking_id)
            break
          end
        end
      end
    rescue => e
      puts "#{__method__} booking #{booking} raise: #{e}"
    end
  end

  formatted_rooms.inject([]) do |result, (room_id, room)|
    result.push(room[:bookings])
    result
  end
end

result = assign_rooms(bookings, rooms)
p result