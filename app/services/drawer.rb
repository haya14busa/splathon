# frozen_string_literal: true

class Drawer

  def initialize(qualifier)
    @qualifier = qualifier
  end

  def swiss_draw
    teams = @qualifier.event.teams.to_a.shuffle.sort_by(&:points)
    matches = []
    loop do
      matches << arrange_match(teams)
      break if teams.blank?
    end
    matches.each(&:save)
  end

  def redraw
    @qualifier.matches.each(&:destroy)
    swiss_draw
  end

  # @param [Array<Team>] team_queue
  # @param [Arary<Team>] temp_queue
  # @return [Match]
  def arrange_match(team_queue, temp_queue = [])
    m = Match.new(qualifier: @qualifier, team: team_queue.shift, opponent: team_queue.shift)
    if m.duplicated?
      temp_queue << m.opponent
      team_queue.unshift(m.team)
    else
      temp_queue.reverse_each { |t| team_queue.unshift(t) }
      return m
    end
    arrange_match(team_queue, temp_queue)
  end
end
