json.extract! lesson, :id, :date, :title, :description, :location, :tag, :created_at, :updated_at
json.url lesson_url(lesson, format: :json)
