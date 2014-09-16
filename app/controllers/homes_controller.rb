class HomesController < ApplicationController


  before_filter :redirect_to_sign_up_when_no_user
  before_filter :login_required, :only=>[:feedback,:send_feedback]

  respond_to :html,:only=>[:index]

  def index
    respond_with do |format|
      format.html { render :seek_template=>:index }
    end
  end

  def faq
    respond_to do |format|
      format.html 
    end
  end
  
  def feedback
    respond_to do |format|
      format.html
    end
  end

  def send_feedback
    @subject=params[:subject]
    @anon=params[:anon]=="true"
    @details=params[:details]

    if @details.blank? || @subject.blank?
      flash[:error]="You must provide a Subject and details"
      render :action=>:feedback
    else
      if ( Seek::Config.recaptcha_setup? ? verify_recaptcha : true) && Seek::Config.email_enabled
        Mailer.feedback(current_user,@subject,@details,@anon,base_host).deliver
        flash[:notice]="Your feedback has been delivered. Thank You."
        redirect_to root_path
      else
        flash[:error] = "Your word verification failed to be validated. Please try again."
        flash[:error] = "SEEK email functionality is not enabled yet" unless Seek::Config.email_enabled
        render :action=>:feedback
      end
    end
  end

  def redirect_to_sign_up_when_no_user
    if User.count == 0
      redirect_to :controller => 'users', :action => 'new'
    end
  end

  def recent_changes
    respond_to do |format|
      format.html
    end
  end

  def seek_intro_demo
     respond_to do |format|
      format.html
    end
  end

  def my_biovel
    respond_to do |format|
      format.html
    end
  end

  private

  RECENT_SIZE=3

  def classify_for_tabs result_collection
    #FIXME: this is duplicated in application_helper - but of course you can't call that from within controller
    results={}

    result_collection.each do |res|
      results[res.class.name] = [] unless results[res.class.name]
      results[res.class.name] << res
    end

    return results
  end

end
