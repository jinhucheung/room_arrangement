#!/bin/env ruby
#frozen_string_literal: true

# 解题思路:
# 1. 根据入住时间从早到晚排序预约
# 2. 优先安排已固定房间的预约，若固定房间已被先预约了，则提醒客人是否更换预约房间
# 3. 对无固定房间的预约，尝试为其安排在入住时间比他退房时间晚的房间预约单前，否则安排他到退房时间比他入住时间早的预约后

require 'date'

ValidationError = Class.new(StandardError)

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

def format_rooms(rooms)
  rooms.inject({}) do |result, room|
    result[room[:id]] = room.merge(bookings: [])
    result
  end
end

def get_bookings_of_rooms(formatted_rooms)
  formatted_rooms.inject([]) do |result, (room_id, room)|
    result.push(room[:bookings])
    result
  end
end

def assign_rooms(bookings, rooms)
  formatted_rooms = format_rooms(rooms)
  formatted_bookings = format_bookings(bookings)

  locked_bookings, unlocked_bookings = formatted_bookings.partition {|_, bookings| bookings[:locked]}
  partitioned_bookings = locked_bookings + unlocked_bookings

  partitioned_bookings.each do |booking_id, booking|
    begin
      raise ValidationError.new('checkin or checkout is invalid') if booking[:checkin_date].nil? || booking[:checkout_date].nil?

      locked_room = formatted_rooms[booking[:room_id]] if booking[:locked]
      if locked_room
        last_booking = formatted_bookings[locked_room[:bookings].last]
        if last_booking.nil? || booking[:checkin_date] >= last_booking[:checkout_date]
          booking[:success] = true
          locked_room[:bookings].push(booking_id)
          next
        else
          raise ValidationError.new("the room #{locked_room[:name]} has been booked, please change")
        end
      end

      formatted_rooms.each do |_, room|
        first_booking = formatted_bookings[room[:bookings].first]
        if first_booking.nil? || booking[:checkout_date] <= first_booking[:checkin_date]
          booking[:success] = true
          room[:bookings].unshift(booking_id)
          break
        end

        last_booking = formatted_bookings[room[:bookings].last]
        if booking[:checkin_date] >= last_booking[:checkout_date]
          booking[:success] = true
          room[:bookings].push(booking_id)
          break
        end
      end

      raise ValidationError.new('sorry, rooms are fully booked') unless booking[:success]
    rescue ValidationError => e
      puts "#{__method__} booking #{booking} : #{e}"
    rescue => e
      puts "#{__method__} booking #{booking} raise: #{e}"
    end
  end

  get_bookings_of_rooms(formatted_rooms)
end

result = assign_rooms(bookings, rooms)
p result