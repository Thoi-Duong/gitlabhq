require_relative 'base_service'

##
# Branch can be deleted either by DeleteBranchService
# or by GitPushService.
#
class AfterBranchDeleteService < BaseService
  attr_reader :branch_name

  def execute(branch_name)
    @branch_name = branch_name

    stop_environments
  end

  private

  def stop_environments
    Ci::StopEnvironmentService
      .new(project, current_user)
      .execute(branch_name)
  end
end
