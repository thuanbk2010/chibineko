class TestsController < ApplicationController
  before_action :set_test, only: [:show, :edit, :edit_description, :update, :destroy]

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.all
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
    gon.test = @test
    gon.resultLabels = @test.result_labels
    gon.results = @test.results
    
    # @test.description = "foo\n bar\nfoo\nbar"
    # puts @test.description
  end

  # GET /tests/new
  def new
    @test = Test.new

    # Duplicate test
    @source = Test.find_by(slug: params[:source])
    if @source
      @test.project_id = @source.project_id
      @test.title = @source.title
      @test.description = @source.description
      @source.set_markdown(false)
      @test.markdown = @source.markdown
    end
    puts @source
  end

  # GET /tests/1/edit
  def edit
    @test.set_markdown(true)
  end

  def edit_description
  end

  # POST /tests
  # POST /tests.json
  def create
    @test = current_user.tests.build(test_params)

    team = Team.find_by(name: params[:test][:team_name])
    project = team.projects.find_by(name: params[:test][:project_name]) if team
    @test.project_id = project.id if project  # TODO: Authority check

    if @test.save
      @test.make_testcase
    end

    # @test = Test.new(test_params)

    # respond_to do |format|
    #   if @test.save
    #     format.html { redirect_to @test, notice: 'Test was successfully created.' }
    #     format.json { render :show, status: :created, location: @test }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @test.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    if @test.update(test_params)
      @test.make_testcase if @test.markdown
      # respond_with @test
      # render json: @test, status: 200
    end
    
    # respond_to do |format|
    #   if @test.update(test_params)
    #     format.html { redirect_to @test, notice: 'Test was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @test }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @test.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to tests_url, notice: 'Test was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = Test.find_by(slug: params[:slug])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_params
      # params.require(:test).permit(:slug, :title, :description, :user_id)
      params.require(:test).permit(:title, :description, :markdown)
    end
end