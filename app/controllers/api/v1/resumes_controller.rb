# app/controllers/api/v1/resumes_controller.rb
require 'pdf-reader'

class Api::V1::ResumesController < ApplicationController
  def parse
    return render json: { error: 'File is required' }, status: :bad_request unless params[:file]

    file = params[:file]
    path = Rails.root.join("tmp", file.original_filename)
    File.open(path, 'wb') { |f| f.write(file.read) }

    begin
      reader = PDF::Reader.new(path.to_s)
      text = reader.pages.map(&:text).join("\n")

      parsed = parse_resume_text(text)

      render json: parsed
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    ensure
      FileUtils.rm_f(path)
    end
  end

  private

  def parse_resume_text(text)
    {
      name: text[/Name[:\-]?\s*(.+)/i, 1],
      email: text[/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i],
      phone: text[/(\+?\d[\d\s\-()]{7,})/, 1],
      skills: text.scan(/\b(Ruby|Rails|Python|JavaScript|SQL|AWS|React|HTML|CSS)\b/i).flatten.uniq,
      experience: text.scan(/(?i)([A-Z][a-zA-Z\s]+)\s*\(\d{4}[-–]\d{4}\)/).flatten,
      education: text.scan(/(?i)(BS|MS|B\.Tech|M\.Tech|Bachelor|Master)[^\.]+\(\d{4}[-–]\d{4}\)/).flatten,
      job_role: classify_role(text)
    }
  end

  def classify_role(text)
    return 'Software Engineer' if text.match?(/Ruby|Rails|Python|JavaScript|Developer|Engineer/i)
    return 'Data Analyst' if text.match?(/Excel|SQL|PowerBI|Analytics|Data/i)
    return 'Product Manager' if text.match?(/Product|Roadmap|Stakeholders|Feature/i)
    'Unknown'
  end
end
