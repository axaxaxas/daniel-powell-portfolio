class MarkovsController < ApplicationController
  # GET /markovs
  # GET /markovs.json
  def index
    @markovs = Markov.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @markovs }
    end
  end

  # GET /markovs/1
  # GET /markovs/1.json
  def show
    @markov = Markov.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @markov }
    end
  end

  # GET /markovs/new
  # GET /markovs/new.json
  def new
    @markov = Markov.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @markov }
    end
  end

  # GET /markovs/1/edit
  def edit
    @markov = Markov.find(params[:id])
  end



  # POST /markovs
  # POST /markovs.json
  def create
    @markov = Markov.new(params[:markov])
    @markov.reset_hash
    Source.where("author = ?", params[:markov][:author]).each do |source|
      @markov.combine_hash_from(source)
    end

    respond_to do |format|
      if @markov.save
        format.html { redirect_to @markov, :notice => 'Markov was successfully created.' }
        format.json { render :json => @markov, :status => :created, :location => @markov }
      else
        format.html { render :action => "new" }
        format.json { render :json => @markov.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /markovs/1
  # PUT /markovs/1.json
  def update
    @markov = Markov.find(params[:id])

    respond_to do |format|
      if @markov.update_attributes(params[:markov])
        format.html { redirect_to @markov, :notice => 'Markov was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @markov.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /markovs/1
  # DELETE /markovs/1.json
  def destroy
    @markov = Markov.find(params[:id])
    @markov.destroy

    respond_to do |format|
      format.html { redirect_to markovs_url }
      format.json { head :no_content }
    end
  end
end
