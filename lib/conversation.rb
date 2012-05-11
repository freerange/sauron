class Conversation
  attr_reader :messages, :repository

  def initialize(message, repository)
    @messages = []
    @repository = repository
    add_message(message)
    @messages.sort_by! { |m| m.date }.reverse!
  end

  def has_reply_from_us?
    most_recent_message_from_non_team_member = messages_from_non_team_members.first
    if most_recent_message_from_non_team_member
      replies = repository.find_replies_to(most_recent_message_from_non_team_member.message_id)
      replies.any? { |m| team.has_member?(m.from) }
    else
      true
    end
  end

  private

  def add_message(message)
    return if message.nil?
    return if messages.include?(message)
    @messages << message
    if message.in_reply_to
      add_message(repository.find_by_message_id(message.in_reply_to))
    end
    repository.find_replies_to(message.message_id).each do |reply|
      add_message(reply)
    end
  end

  def team
    @team ||= Team.new
  end

  def messages_from_non_team_members
    messages.reject { |m| team.has_member?(m.from) }
  end
end