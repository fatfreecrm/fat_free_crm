# frozen_string_literal: true

class ConvertToActiveStorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    get_blob_id = case ENV['CI'] && ENV['DB']
                  when 'sqlite'
                    'LAST_INSERT_ROWID()'
                  when 'mysql'
                    'LAST_INSERT_ID()'
                  when 'postgres'
                    'LASTVAL()'
                  else
                    'LASTVAL()'
                  end

    ActiveRecord::Base.connection.raw_connection.then do |conn|
      if conn.is_a?(::PG::Connection)
        conn.prepare('active_storage_blobs', <<-SQL)
          INSERT INTO active_storage_blobs (
            key, filename, content_type, metadata, byte_size, checksum, created_at
          ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
        SQL

        conn.prepare('active_storage_attachments', <<-SQL)
          INSERT INTO active_storage_attachments (
            name, record_type, record_id, blob_id, created_at
          ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
        SQL
      else
        conn.raw_connection.prepare(<<-SQL)
          INSERT INTO active_storage_blobs (
            `key`, filename, content_type, metadata, byte_size, checksum, created_at
          ) VALUES (?, ?, ?, '{}', ?, ?, ?)
        SQL

        conn.raw_connection.prepare(<<-SQL)
          INSERT INTO active_storage_attachments (
            name, record_type, record_id, blob_id, created_at
          ) VALUES (?, ?, ?, #{get_blob_id}, ?)
        SQL
      end
    end

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject { |model| model.abstract_class? || model == ActionMailbox::InboundEmail || model == ActionText::RichText }

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          ::Regexp.last_match(1) if c =~ /(.+)_file_name$/
        end.compact

        next if attachments.blank?

        model.find_each.each do |instance|
          attachments.each do |attachment|
            next if instance.send(attachment).path.blank?

            ActiveRecord::Base.connection.execute_prepared(
              'active_storage_blob_statement', [
                key(instance, attachment),
                instance.send("#{attachment}_file_name"),
                instance.send("#{attachment}_content_type"),
                instance.send("#{attachment}_file_size"),
                checksum(instance.send(attachment)),
                instance.updated_at.iso8601
              ]
            )

            ActiveRecord::Base.connection.execute_prepared(
              'active_storage_attachment_statement', [
                attachment,
                model.name,
                instance.id,
                instance.updated_at.iso8601
              ]
            )
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def key(_instance, _attachment)
    SecureRandom.uuid
    # Alternatively:
    # instance.send("#{attachment}_file_name")
  end

  def checksum(attachment)
    # local files stored on disk:
    url = attachment.path
    Digest::MD5.base64digest(File.read(url))

    # remote files stored on another person's computer:
    # url = attachment.url
    # Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
  end
end
