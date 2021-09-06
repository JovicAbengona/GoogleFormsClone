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

    def create
        @form_action = "publish"
        @form_data = Form.get_form_by_code current_user["id"], params[:code]
        @questions = Question.get_questions_by_ids @form_data['id'], JSON.parse(@form_data['question_order'])
        @all_options = Option.collect_options_per_quetions JSON.parse(@form_data['question_order'])

        if @form_data["status"] === 1
            @form_action = "end"
        end
    end

    def create_form
        new_form = Form.create_form(current_user["id"])

        if new_form[:status] 
            return redirect_to "/f/#{new_form[:form_code]}"
        end     
    end

    def rename_form
        form_data = params.require(:form).permit(:title)

        validate_rename = Form.validate_rename(params[:id], current_user["id"], form_data)

        render json: validate_rename
    end

    def publish_form
        status = Form.publish_form(params[:id], current_user["id"])

        if status
            flash[:publish_message] = { :alert_type => "success", :message => "Form has been published!", :icon => "check" }
        else
            flash[:publish_message] = { :alert_type => "danger", :message => "Unable to publish form!", :icon => "times" }
        end

        redirect_to "/f/#{params[:code]}"
    end

    def delete
        status = Form.delete_form(params[:id], current_user["id"])

        if status
            flash[:delete_message] = { :alert_type => "success", :message => "Form has been deleted!", :icon => "check" }
        else
            flash[:delete_message] = { :alert_type => "danger", :message => "Unable to delete form!", :icon => "times" }
        end

        redirect_to "/"
    end

    def view
    end

    def result
    end

    def answer
        render "view"
    end
end
