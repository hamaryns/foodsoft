# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application

namespace :foodsoft do

  # "rake foodsoft:create_admin"
  desc "creates Administrators-group and admin-user"
  task :create_admin => :environment do
    puts "Create Workgroup 'Administators'"
    administrators = Workgroup.create(
      :name => "Administrators",
      :description => "System administrators.",
      :role_admin => true,
      :role_finance => true,
      :role_article_meta => true,
      :role_suppliers => true,
      :role_orders => true
    )

    puts "Create User 'admin' with password 'secret'"
    admin = User.create(:nick => "admin", :first_name => "Anton", :last_name => "Administrator",
      :email => "admin@foo.test", :password => "secret")

    puts "Joining 'admin' user to 'Administrators' group"
    Membership.create(:group => administrators, :user => admin)
  end

  desc "Notify users of upcoming tasks"
  task :notify_upcoming_tasks => :environment do
    tasks = Task.find :all, :conditions => ["done = ? AND due_date = ?", false, 1.day.from_now.to_date]
    for task in tasks
      puts "Send notifications for #{task.name} to .."
      for user in task.users
        if user.settings['notify.upcoming_tasks'] == 1
          puts "#{user.email}.."
          Mailer.deliver_notify_upcoming_tasks(user,task)
        end
      end
    end
  end
end