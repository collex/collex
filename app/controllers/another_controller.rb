class AnotherController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @task_email_pages, @task_emails = paginate :task_emails, :per_page => 10
  end

  def show
    @task_email = TaskEmail.find(params[:id])
  end

  def new
    @task_email = TaskEmail.new
  end

  def create
    @task_email = TaskEmail.new(params[:task_email])
    if @task_email.save
      flash[:notice] = 'TaskEmail was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @task_email = TaskEmail.find(params[:id])
  end

  def update
    @task_email = TaskEmail.find(params[:id])
    if @task_email.update_attributes(params[:task_email])
      flash[:notice] = 'TaskEmail was successfully updated.'
      redirect_to :action => 'show', :id => @task_email
    else
      render :action => 'edit'
    end
  end

  def destroy
    TaskEmail.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
