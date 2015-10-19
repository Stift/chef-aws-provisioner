module ChefAWSProvisioner
  module Utils
    # Decodes a randomly generated AWS administrator password for a Windows instance.
    #
    # @param instance_id [String] The ID of the Windows instance.
    # @param key_file_path [String] The path to a private key of a key pair used to encrypt the password.
    # @param sleep_time [Integer] The amount of seconds to sleep inbetween tries to look up the password.
    #
    # @return [String] The decrypted password.
    def decode_windows_password(instance_id, _key_pair_path, sleep_time = 5)
      instance = ec2.instances[instance_id]
      encrypted_password = nil
      until encrypted_password
        sleep sleep_time
        encrypted_password = instance.password_data
      end
      instance.decrypt_windows_password
    end
  end
end
