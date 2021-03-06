class FormsController < ApplicationController
    # DOCU: (GET) /dashboard
	# Get forms based on current_user["id"]
	# Triggered by: visting /dashboard
    # Requires: current_user["id"]
    # Returns: Hash data containing details about each form
    # Last Updated: September 3, 2021
    # Owner: Jovic Abengona
    def dashboard
        @forms = Form.get_forms(current_user["id"])
    end

    # DOCU: (GET) /f/:code/create
    # Get form data based on current user and form code
    # Triggered by: create_form method or updating a form
    # Requires: current user logged in and the form code
    # Returns: Form data, question data by form id and question order, and options per question
    # Last Update date: September 13, 2021
    # Owner: Fitz, Updated By: Jovic Abengona
    def create
        @form_data = Form.get_form_by_code current_user["id"], params[:code]
        if @form_data.nil?
            redirect_to "/dashboard"
        else
            @questions = Question.get_questions_by_ids @form_data['id'], JSON.parse(@form_data['question_order'])
            @all_options = Option.collect_options_per_quetions JSON.parse(@form_data['question_order'])
            @form_action = "publish"
            @has_other = false

            if @form_data["status"] === STATUS_PUBLISHED
                @form_action = "get_result"
            elsif @form_data["status"] === STATUS_FINISHED
                @form_action = "show_result"
            end
        end
    end

    def quiz_mode_toggle
        render json: Form.quiz_mode_toggle(params[:form_id], params[:quiz_mode_toggle], current_user["id"])
    end

    # DOCU: (GET) /f/:code/preview
	# Get form data including questions and options
	# Triggered by: visting /f/:code/preview
    # Requires: current_user["id"], params[:code]
    # Returns: Instance variables for forms data, questions, and options
    # Last Updated: September 6, 2021
    # Owner: Jovic Abengona
    def preview
        @form_data = Form.get_form_by_code(current_user["id"], params[:code])
        @questions = Question.get_questions_by_ids(@form_data['id'], JSON.parse(@form_data['question_order']))
        @all_options = Option.collect_options_per_quetions(JSON.parse(@form_data['question_order']))
    end

    # DOCU: (GET) /create_form
    # Create a new form with question and a option in default format
    # Triggered by: Clicking create new form 
    # Requires: current user logged in 
    # Returns: Redirect to create URL
    # Owner: Fitz
    # Last Update date: September 3, 2021
    def create_form
        new_form = Form.create_form(current_user["id"])

        if new_form[:status] 
            return redirect_to "/f/#{new_form[:form_code]}/create"
        end     
    end

    # DOCU: (PATCH) /form/update_question_order
	# Update question_order of form
	# Triggered by: sending a PATCH request to /form/update_question_order
    # Requires: current_user["id"], form_params[:id], and question_ids
    # Returns: Output of update_question_order (true or false)
    # Last Updated: September 10, 2021
    # Owner: Jovic Abengona
    def update_question_order
        form_params = params.require(:form).permit(:id)
        question_ids = params[:question_ids].split(",")

        render json: Form.update_question_order(current_user["id"], form_params[:id], question_ids)
    end

    # DOCU: (GET) /add_question/:form_id
    # Add a new question in form, update question order of the form, and render it to user
    # Triggered by: Clicking add question
    # Owner: Fitz 
    def add_question
        form_param = params.require(:form).permit(:id)

        render json: Question.add_new_question(form_param)
    end

    # DOCU: (GET) /add_option/:question_id
    # Add a new option in default format
    # Triggered by: Clicking add option
    # Owner: Fitz
    def add_option
        render json: Option.create_default_option(params[:question_id])
    end

    # DOCU: (GET) /add_others_option/:question_id
    # Add a new Others option 
    # Triggered by: Clicking on add others
    # Owner: Fitz
    def add_others_option
        render json: Option.add_others_option(params[:question_id])
    end

    # DOCU: (PATCH) /update_form_title_and_description
    # Triggered by: Changing Form Title or Description Input text box
    # Last Update date: September 7, 2021
    # Owner: Fitz, Updated by Jovic Abengona
    def update_form_title_and_description
        form_params = params.require(:form).permit(:id, :title, :description)

        render json: Form.update_form_title_and_description(current_user["id"], form_params)
    end

    # DOCU: (PATCH) /update_question_content
    # Triggered by: Changing of Question content Input text box
    # Owner: Fitz
    def update_question_content
        question_params = params.require(:question).permit(:id, :content)

        render json: Question.update_question_content(question_params)
    end

    # DOCU: (PATCH) /update_question_type
    # Triggered by: Changing drop-down menu for question type
    # Owner: Fitz
    def update_question_type
        form_params = params.require(:form).permit(:question_id, :question_type)

        render json: Question.update_question_type(form_params)
    end

    # DOCU: (PATCH) /update_option_content
    # Triggered by: Changing Option content input text box
    # Owner: Fitz
    def update_option_content
        option_params = params.require(:option).permit(:id, :content)

        render json: Option.update_option_content(option_params)
    end

    # DOCU: (DELETE) /delete_option
    # Triggered by: Clicking on the Delete Option 
    # Owner: Fitz
    def delete_option
        option_param = params.permit(:id)

        render json: Option.delete_option(option_param)
    end

    # DOCU: (DELETE) /delete_question
    # Triggered by: Clicking on the Delete Question
    # Owner: Fitz
    def delete_question
        question_params = params.permit(:id, :form_id, :question_type_id)

        render json: Question.delete_question(question_params)
    end

    # DOCU: (PATCH) /update_score
    # Triggered by: Changing Score input text box
    # Owner: Fitz
    def update_score
        question_params = params.require(:question).permit(:id, :score)

        render json: Question.update_score(question_params)
    end

    # DOCU: (PATCH) /update_correct_answer
    # Triggered by: Clicking on the checkbox for choosing the correct answer
    # Owner: Fitz
    def update_correct_answer
        question_params = params.permit(:question_id, :question_type_id, :option_id)
        
        render json: Question.update_correct_option(question_params)
    end

    # DOCU: (POST) /form/rename/:id
	# Validate form_data then rename form title
	# Triggered by: Sending POST request to /form/rename/:id
    # Requires: params[:id], current_user["id"], form_data
    # Returns: Hash data containing :status, :errors, and :form_data
    # Last Updated: September 3, 2021
    # Owner: Jovic Abengona
    def rename_form
        form_data = params.require(:form).permit(:id, :title)

        render json: Form.validate_rename(current_user["id"], form_data)
    end

    # DOCU: (POST) /form/publish/:id/:code
	# Update form status then return a flash data
	# Triggered by: Sending POST request to /form/publish/:id/:code
    # Requires: params[:id], current_user["id"]
    # Returns: Flash data containing :alert_type, :message, and :icon
    # Last Updated: September 6, 2021
    # Owner: Jovic Abengona
    def publish_form
        form_data = params.require(:form).permit(:id)

        render json: Form.publish_form(form_data[:id], current_user["id"])
    end

    # DOCU: (PATCH) /form/get_result
	# Update form status then return Hash data
	# Triggered by: Sending PATCH request to /form/get_result
    # Requires: form_data[:id], current_user["id"]
    # Returns: Hash data containing :status, and :code
    # Last Updated: September 13, 2021
    # Owner: Jovic Abengona
    def get_result
        form_data = params.require(:form).permit(:id)

        render json: Form.get_result(form_data[:id], current_user["id"])
    end

    # DOCU: (POST) /form/delete/:id
	# Delete form then return a flash data
	# Triggered by: Sending POST request to /form/delete/:id
    # Requires: params[:id], current_user["id"]
    # Returns: Flash data containing :alert_type, :message, and :icon
    # Last Updated: September 6, 2021
    # Owner: Jovic Abengona
    def delete
        form_data = params.require(:form).permit(:id)

        status = Form.delete_form(form_data[:id], current_user["id"])

        if status
            flash[:delete_message] = { :alert_type => "success", :message => "Form has been deleted!", :icon => "check" }
        else
            flash[:delete_message] = { :alert_type => "danger", :message => "Unable to delete form!", :icon => "times" }
        end

        redirect_to "/"
    end

    # DOCU: (GET) /f/:code/results
    # Access Form results
    # Requires: Form code and current user
    # Returns: Answers data
    # Owner: Fitz
    def result
        @results_data = Answer.get_results(params[:code], current_user["id"])
    end

    # DOCU: (GET) /f/:code
    # Access Form for answering
    # Requires: Form code and current user
    # Returns: Form data
    # Owner: Fitz
    def answer
        @form_data = Form.get_published_form(params[:code])
        if @form_data.nil?
            redirect_to "/dashboard"
        else
            @questions = Question.get_questions_by_ids(@form_data['id'], JSON.parse(@form_data['question_order']))
            @all_options = Option.collect_options_per_quetions(JSON.parse(@form_data['question_order']))
        end
    end

    # DOCU: (POST) /submit_form
    # Submit Form answered by current User
    # Requires: Form code and current user
    # Returns: Status if successful or not
    # Owner: Fitz
    def submit_form
        answers_params = params.permit!

        render json: Answer.insert_answers(answers_params, current_user["id"])
    end
end
