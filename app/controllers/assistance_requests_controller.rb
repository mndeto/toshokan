require 'library_support'

class AssistanceRequestsController < CatalogController

  include ResolverHelper

  def index
    if can? :request, :assistance
      if can? :view, :all_assistance_requests
        @assistance_requests = AssistanceRequest.all
      elsif can? :view, :own_assistance_requests
        @assistance_requests = AssistanceRequest.find_by_user_id current_user.id
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def new
    if can? :request, :assistance
      @genre = genre_from params

      if @genre
        @assistance_request = assistance_request_from(params) || assistance_request_for(@genre)
        head :bad_argument and return unless @assistance_request
      else
        head :bad_request
      end
    else
      render 'cant_request_assistance'
    end
  end

  def create
    if can? :request, :assistance
      genre = genre_from params

      if genre
        assistance_request = assistance_request_from params

        if assistance_request
          assistance_request.user = current_user
          assistance_request.email = current_user.email

          action = params[:button] || :create

          unless can? :select, :pickup_location
            assistance_request.physical_location = current_user.address
          end

          case action.to_sym
          when :confirm
            if assistance_request.valid?
              assistance_request.save!
              LibrarySupport.delay.submit_assistance_request current_user, assistance_request, assistance_request_url(:id => assistance_request.id)
              SendIt.delay.send_book_suggestion current_user, params[:assistance_request] if assistance_request.book_suggest
              flash[:notice] = 'Your request was sent to a librarian'
              redirect_to assistance_request_path(assistance_request)
            else
              flash[:error] = assistance_request.errors
              redirect_to new_assistance_request_path(assistance_request)
            end
          else
            @genre = genre
            @assistance_request = assistance_request

            if show_feature?(:cff_resolver)
              if assistance_request.valid?
                Rails.logger.info "CFF request"
                if params[:resolved]
                  Rails.logger.info "CFF ignored resolver results"
                else
                  # make resolver lookup
                  openurl = assistance_request.openurl
                  (count, response, document) = get_resolver_result(openurl.to_hash)
                  Rails.logger.info "CFF #{count} resolver results"
                  if count > 0
                    # redirect to resolver controller with assistance request params
                    openurl_str = openurl.kev
                    openurl_str.slice!(/&ctx_tim=[^&]*/)
                    redirect_to resolve_path + "?#{openurl_str}&#{{'assistance_request' => params['assistance_request']}.to_query}&assistance_genre=#{params["genre"]}" and return
                  end
                end
              else
                flash.now[:error] = 'One or more required fields are empty'
                params.delete :button
                render :new
              end
            else
              unless assistance_request.valid?
                flash.now[:error] = 'One or more required fields are empty'
                params.delete :button
                render :new
              end
            end
          end
        else
          head :bad_request
        end
      else
        head :bad_request
      end
    else
      head :not_found
    end
  end

  def show
    if can? :request, :assistance
      if AssistanceRequest.exists? params[:id]
        @assistance_request = AssistanceRequest.find params[:id]
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def resend
    if can? :resend, LibrarySupport
      if AssistanceRequest.exists? params[:id]
        @assistance_request = AssistanceRequest.find params[:id]
        LibrarySupport.delay.submit_assistance_request current_user, @assistance_request, assistance_request_url(:id => @assistance_request.id), true
        SendIt.delay.send_book_suggestion current_user, params[:assistance_request] if @assistance_request.book_suggest
        render :show
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def genre_from params
    params[:genre].to_sym if params[:genre]
  end

  def assistance_request_from params
    case genre_from params
    when :journal_article
      JournalArticleAssistanceRequest.new params[:assistance_request]
    when :conference_article
      ConferenceArticleAssistanceRequest.new params[:assistance_request]
    when :book
      BookAssistanceRequest.new params[:assistance_request]
    end
  end

  def assistance_request_for genre
    case genre
    when :journal_article
      JournalArticleAssistanceRequest.new
    when :conference_article
      ConferenceArticleAssistanceRequest.new
    when :book
      BookAssistanceRequest.new
    end
  end
end
