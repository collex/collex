class ApprovalController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @approval_pages, @approvals = paginate :approvals, :per_page => 10
  end

  def show
    @approval = Approval.find(params[:id])
  end

  def new
    @approval = Approval.new
  end

  def create
    @approval = Approval.new(params[:approval])
    if @approval.save
      flash[:notice] = 'Approval was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @approval = Approval.find(params[:id])
  end

  def update
    @approval = Approval.find(params[:id])
    if @approval.update_attributes(params[:approval])
      flash[:notice] = 'Approval was successfully updated.'
      redirect_to :action => 'show', :id => @approval
    else
      render :action => 'edit'
    end
  end

  def destroy
    Approval.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
