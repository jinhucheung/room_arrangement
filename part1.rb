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

def assign_rooms(bookings, num_of_rooms)
  assigned_rooms = Array.new(num_of_rooms.to_i) { Array.new }
  booking_id_of_assigned_rooms = Array.new(num_of_rooms.to_i) { Array.new }

  if bookings
    bookings_sort_by_checkin = bookings.sort_by {|booking| Date.parse(booking[:checkin]).to_time.to_i rescue Date::Infinity.new}

    bookings_sort_by_checkin.each do |booking|
      begin
        assigned_rooms.each_with_index do |room, index|
          last_booking = room.last
          if last_booking.nil? || Date.parse(booking[:checkin]) >= Date.parse(last_booking[:checkout])
            room.push(booking)
            booking_id_of_assigned_rooms[index].push(booking[:id])
            break
          end
        end
      rescue => e
        puts "#{__method__} booking #{booking} raise: #{e}"
      end
    end
  end

  booking_id_of_assigned_rooms
end

num_of_rooms = 3
p format_bookings(bookings)
result = assign_rooms(bookings, num_of_rooms)
p result