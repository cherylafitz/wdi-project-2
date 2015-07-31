class ProfileController < ApplicationController
  before_action :is_authenticated?

  def index
    Indeed.key=ENV['INDEED_KEY']

    # gets jobkeys to use in methods
    @jobs = current_user.jobs

    @jobkey_arr = current_user.jobs.map do |job|
      @job_key = job. jobkey
    end

    # checks if jobs have been removed, if yes, deletes them from user's job board
    @jobkey_arr.each do |key|
      scrape_website key
    if key.nil?
      j = Job.find params[:id]
      j.delete
      end
    end

    # makes hash for word clouds
    @job_descriptions_hash = @jobkey_arr.map {|job_key|
      @job_desc_string = get_job_description job_key
      @job_arr = string_to_arr @job_desc_string
      words_to_hash @words
    }
    gon.job_desc = @job_descriptions_hash

    # creates array of resume words
    if current_user.resume
      resume = current_user.resume
      @resume_array = string_to_arr resume
    end

    # generates match score
    @matchscore_arr = @jobkey_arr.map do |job_key|
      @job_desc_string = get_job_description job_key
      @job_arr = string_to_arr @job_desc_string
      puts "trying to put jobarr"
      puts @job_arr
      puts "this is right before the problem"
      puts @job_arr
      @jl = @job_arr.length
      unless @resume_array.nil?
        rl = @resume_array.length
      @comparison_arr = @job_arr & @resume_array
      end
      unless @comparison_arr.nil?
        cl = @comparison_arr.length
      percent_shared_words = (cl.to_f / @jl.to_f) * 100
      percent_shared_words.round
      end
    end

    # associates matchscore with jobs
    @matchscore_arr.length.times do |i|
      @jobs[i].matchscore = @matchscore_arr[i]
      @jobs[i].save
    end

    @job_descriptions_hash
    @comparison_arr = @matchscore_arr
    # render json: current_user.jobs
    # render plain: @resume
  end

  def edit
  end

  def destroy
    result = Job.destroy params[:id]
    respond_to do |format|
      format.html {redirect_to profile_path}
      format.json {render json: result}
    end

  end

  def update
    @current_user = current_user.id
    current_user.update params[:resume]
    redirect_to profile_path
  end

  # adds job to table after user selects it on the search page
  def add_job
    @jobkey = params[:id]
    p @jobkey
    @description = get_job_description @jobkey
    @job_location = get_location @jobkey
    @company = get_company @jobkey
    @job_title = get_job_title @jobkey
    current_user.jobs.find_or_create_by(jobkey:@jobkey,description:@description,
      title:@job_title,company:@company,location:@job_location)
    redirect_to profile_path
  end

end
