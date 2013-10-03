require File.expand_path('../test_helper.rb', __FILE__)

Delayed::Worker.max_attempts = 1
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 20
Delayed::Worker.max_run_time = 30
Delayed::Worker.read_ahead = 5
Delayed::Worker.delay_jobs = true

Dummy::Application.routes.draw do
  mount DjMon::Engine=> 'dj_mon'
end

class ApiTest < ActionDispatch::IntegrationTest

  setup { Delayed::Job.destroy_all }

  context "authorization" do
    %w(all failed active queued dj_counts settings).each do |protected_get|
      should "not allow unauthorized GET to /dj_reports/#{protected_get}" do
        unauthorized_get "/dj_mon/dj_reports/#{protected_get}", :format=> 'json'

        assert_equal 401, status
      end
    end

    should "not allow unauthorized POST access to /dj_reports/retry" do
      unauthorized_post "/dj_mon/dj_reports/100/retry/", :format=> 'json'
      assert_equal 401, status
    end

    should "not allow unauthorized DELETE access to /dj_reports/delete" do
      unauthorized_delete "/dj_mon/dj_reports/100/", :format=> 'json'
      assert_equal 401, status
    end
  end

  context "GET /dj_counts" do
    setup do
      build_active_jobs(:count=> 1)
      build_failed_jobs(:count=> 2)
      build_queued_jobs(:count=> 3)
    end

    should "have counts for all, active, queued, failed jobs" do
      authorized_get '/dj_mon/dj_reports/dj_counts', :format=> 'json'

      assert_equal 200, status
      assert_equal({ :all=> 6, :active=> 1, :failed=> 2, :queued=> 3 }, json_response.symbolize_keys)
    end
  end

  context "GET /settings" do
    should "return delayed job settings" do
      authorized_get '/dj_mon/dj_reports/settings', :format=> 'json'

      assert_equal 200, status

      assert_equal 1, json_response['max_attempts']
      assert_equal 20, json_response['sleep_delay']
      assert_equal 30, json_response['max_run_time']
      assert_equal 5, json_response['read_ahead']

      assert json_response['delay_jobs']
      assert !json_response['destroy_failed_jobs']
      assert_match /\d+\.\d+.\d+/, json_response['delayed_job_version']
      assert_match /\d+\.\d+.\d+/, json_response['dj_mon_version']
    end
  end

  context "GET /failed" do
    setup do
      build_failed_jobs({ :count=> 2, :queue=> "queue_mailer_1", :priority=> 3 })
    end

    should "return details of failed jobs" do
      authorized_get '/dj_mon/dj_reports/failed', :format=> 'json'

      assert_equal 2, json_response.size
      assert_job({:failed=> true, :priority=> 3, :attempts=> 1, :queue=> 'queue_mailer_1'}, json_response.first)
    end
  end

  context "GET /queued" do
    setup do
      build_queued_jobs(:count=> 3, :priority=> 2, :queue=> "queue_mailer_2")
    end

    should "return details of queued jobs" do
      authorized_get '/dj_mon/dj_reports/queued', :format=> 'json'

      assert_equal 3, json_response.size
      assert_job({:failed=> false, :priority=> 2, :attempts=> 0, :queue=> 'queue_mailer_2'}, json_response.first)
    end
  end

  context "GET /active" do
    setup do
      build_active_jobs(:count=> 2, :priority=> 2, :queue=> "queue_mailer_3")
    end

    should "return details of active jobs" do
      authorized_get '/dj_mon/dj_reports/active', :format=> 'json'

      assert_equal 2, json_response.size
      assert_job({:failed=> false, :priority=> 2, :attempts=> 0, :queue=> 'queue_mailer_3'}, json_response.first)
    end
  end

  context "GET /all" do
    setup do
      build_failed_jobs({ :count=> 1, :priority=> 1, :queue=> "queue_mailer_1" })
      build_queued_jobs(:count=> 1, :priority=> 2, :queue=> "queue_mailer_2")
      build_active_jobs({ :count=> 1, :priority=> 3, :queue=> 'queue_mailer_3' })
    end

    should "return details of queued, failed and active jobs" do
      authorized_get '/dj_mon/dj_reports/all', :format=> 'json'

      assert_equal 3, json_response.size
      assert_job_in_queue('queue_mailer_1', { :failed=> true,  :priority=> 1, :attempts=> 1, :queue=> 'queue_mailer_1' })
      assert_job_in_queue('queue_mailer_2', { :failed=> false, :priority=> 2, :attempts=> 0, :queue=> 'queue_mailer_2' })
      assert_job_in_queue('queue_mailer_3', { :failed=> false, :priority=> 3, :attempts=> 0, :queue=> 'queue_mailer_3' })
    end
  end

  context "GET /all with malformed job" do
    setup do
      build_failed_jobs({ :count=> 1, :priority=> 1, :queue=> "queue_mailer_1" })
      build_queued_jobs(:count=> 1, :priority=> 2, :queue=> "queue_mailer_2")
      build_active_jobs({ :count=> 1, :priority=> 3, :queue=> 'queue_mailer_3' })
      build_syntax_error_jobs({ :count=> 1, :priority=> 3, :queue=> 'queue_mailer_4' })
    end

    should "replace the payload if payload is malformed" do
      authorized_get '/dj_mon/dj_reports/all', :format=> 'json'
      assert_equal 4, json_response.size
      assert_job_in_queue('queue_mailer_4', { :failed=> false, :syntax_error=> true, :priority=> 3, :attempts=> 0, :queue=> 'queue_mailer_4' })
    end
  end


  context "DELETE /:id" do
    should "delete the job specified by the :id" do
      job = build_failed_jobs.first
      authorized_delete "/dj_mon/dj_reports/#{job.id}", :format=> 'json'

      assert Delayed::Job.where(:id=> job.id).empty?
      assert response.body.strip.empty?
    end
  end

  context "POST /retry/:id" do
    should "reset failed_at column so that delayed job retries it" do
      job = build_failed_jobs.first
      authorized_post "/dj_mon/dj_reports/#{job.id}/retry", :format=> 'json'

      assert_nil job.reload.failed_at
      assert response.body.strip.empty?
    end
  end

  private

  def build_queued_jobs(options = {})
    options = { :count=> 1, :priority=> 1, :queue=> 'queue_mailer' }.merge(options)
    options[:count].times.map do
      Delayed::Job.enqueue(TestJob.new, :priority=> options[:priority], :queue=> options[:queue])
    end
  end

  def build_active_jobs(options = {})
    options = { :count=> 1, :priority=> 1, :queue=> 'queue_mailer' }.merge(options)
    options[:count].times.map do
      job = Delayed::Job.enqueue(TestJob.new, :priority=> options[:priority], :queue=> options[:queue])
      job.update_attributes({:locked_at=> Time.current, :locked_by=> 'some-worker'})
      job
    end
  end

  def build_failed_jobs(options = {})
    options = { :count=> 1, :priority=> 1, :queue=> 'queue_mailer' }.merge(options)
    options[:count].times.map do
      job = Delayed::Job.enqueue(FailingTestJob.new, :priority=> options[:priority], :queue=> options[:queue])
      worker.run(job)
      job
    end
  end

  def build_syntax_error_jobs(options = {})
    options = { :count=> 1, :priority=> 1, :queue=> 'queue_mailer' }.merge(options)
    malformed_yaml = "--- !ruby/object:TestJob {what:'no\n"
    options[:count].times.map do
      job = Delayed::Job.enqueue(TestJob.new, :priority=> options[:priority], :queue=> options[:queue])
      job.handler = malformed_yaml
      job.update_attributes({:locked_at=> Time.current, :locked_by=> 'some-worker'})
      job
    end
  end

  def worker
    Delayed::Worker.new
  end

  def assert_job(expected, actual)
    assert_equal expected[:failed], actual['failed']
    assert_match /\d+/, actual['id'].to_s
    assert_equal expected[:priority], actual['priority']
    assert_equal expected[:attempts], actual['attempts']
    assert_equal expected[:queue], actual['queue']
    if expected[:failed]
      assert_equal "--- !ruby/object:FailingTestJob {}", actual['payload'].strip
      assert actual['last_error'].include?("this one fails")
      assert actual['last_error_summary'].include?("this one fails")
      assert_not_nil DateTime.strptime(actual['failed_at'], DjMon::DjReport::TIME_FORMAT)
    elsif expected[:syntax_error]
      # Gross hack to make this assertion compat with Ruby 1.8.7 and 1.9.3
      # - 1.8.7 throws DelayedJob::DeserializationError
      # - 1.9.3 throws Psych::SyntaxError
      assert_match /SyntaxError|DeserializationError/, actual['payload'].strip
      assert actual['failed_at'].empty?
      assert_nil actual['last_error']
      assert actual['last_error_summary'].empty?
    else
      assert_equal "--- !ruby/object:TestJob {}", actual['payload'].strip
      assert actual['failed_at'].empty?
      assert_nil actual['last_error']
      assert actual['last_error_summary'].empty?
    end
    assert_not_nil DateTime.strptime(actual['created_at'], DjMon::DjReport::TIME_FORMAT)
    assert_not_nil DateTime.strptime(actual['run_at'], DjMon::DjReport::TIME_FORMAT)
  end

  def assert_job_in_queue queue, expected
    job = json_response.find{|j| j['queue'] == queue}
    assert_not_nil job
    assert_job expected, job
  end

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end

  def authorized_get(url, params)
    get url, params, authorization_header('dj_mon', 'password')
  end

  def unauthorized_get(url, params)
    get url, params, authorization_header('dj_mon', 'gibber')
  end

  def authorized_post(url, params)
    post url, params, authorization_header('dj_mon', 'password')
  end

  def unauthorized_post(url, params)
    post url, params, authorization_header('dj_mon', 'gibber')
  end

  def authorized_delete(url, params)
    delete url, params, authorization_header('dj_mon', 'password')
  end

  def unauthorized_delete(url, params)
    delete url, params, authorization_header('dj_mon', 'gibber')
  end

  def authorization_header user, password
    { 'HTTP_AUTHORIZATION'=> ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
  end

end
