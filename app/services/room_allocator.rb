# frozen_string_literal: true

class RoomAllocator
  def initialize(qualifier)
    @qualifier = qualifier.reload
    @matches = @qualifier.matches
    @rooms = @qualifier.event.rooms
  end

  def allocate
    # 必要な部屋リソースを確保
    # 優先度の高い部屋が多くなるようにしている
    room_stocks = @rooms.order(priority: :desc)
                        .cycle(@matches.count)
                        .to_a
                        .slice(0...@matches.count)
                        .sort { |a, b| a.priority <=> b.priority }
                        .reverse

    # 初戦を除きあとのほうがより強いチームになるので、優先度高い部屋を割り当てるようにする
    # @matches.first.update!(room: room_stocks.shift)

    # 残りの試合は、優先度高い部屋の利用が少ないチームが割り当てられるようにする
    @matches.where(room: nil).shuffle.sort { |a, b| a.room_priority <=> b.room_priority }.each do |match|
      match.update!(room: room_stocks.shift)
    end

    # 部屋ごとの試合順(matches.order)を設定する
    @qualifier.matches.order(room_id: :asc, id: :desc).group_by(&:room_id).each do |room_id, room_matches|
      room_matches.each.with_index(1) do |match, i|
        match.update!(order: i)
      end
    end
  end
end
