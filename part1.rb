#!/bin/env ruby
#frozen_string_literal: true

require 'date'

bookings = [
  {
    checkin: '2017-10-1',
    checkout: '2017-10-3',
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

def assign_rooms(bookings, num_of_rooms)
  assigned_rooms = Array.new(num_of_rooms.to_i) {Array.new}

  if bookings
    formatted_bookings = format_bookings(bookings)

    formatted_bookings.each do |booking_id, booking|
      begin
        raise 'checkin or checkout is invalid' if booking[:checkin_date].nil? || booking[:checkout_date].nil?

        assigned_rooms.each do |room|
          last_booking = formatted_bookings[room.last]

          if last_booking.nil? || booking[:checkin_date] >= last_booking[:checkout_date]
            room.push(booking_id)
            break
          end
        end
      rescue => e
        puts "#{__method__} booking #{booking} raise: #{e}"
      end
    end
  end

  assigned_rooms
end

num_of_rooms = 3
result = assign_rooms(bookings, num_of_rooms)
p result