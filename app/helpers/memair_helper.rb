module MemairHelper

  def generate_recommendation_mutation(recommendations)
    recommendation_strings = recommendations.map { |recommendation|
      """
        {
          type: video
          source: \"Kid Friendly Videos\"
          priority: #{recommendation.priority}
          expires_at: \"#{recommendation.expires_at}\"
          url: \"https://youtu.be/#{recommendation.yt_id}\"
          title: \"#{recommendation.title.gsub('"', '\"')}\"
          description: \"#{recommendation.description.gsub('"', '\"')}\"
          thumbnail_url: \"#{recommendation.thumbnail_url}\"
          duration: #{recommendation.duration}
          published_at: \"#{recommendation.published_at}\"
        }
      """
    }

    """
      mutation {
        Create(
          recommendations: [
            #{recommendation_strings.join}
          ]
        )
        {
          id
        }
      }
    """
  end
end
