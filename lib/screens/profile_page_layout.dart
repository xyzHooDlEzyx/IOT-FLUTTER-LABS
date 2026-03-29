part of 'profile_page.dart';

mixin _ProfilePageLayout on _ProfilePageLogic {
  @override
  Widget build(BuildContext context) {
    final user = _user;

    return AppShell(
      title: 'Profile',
      subtitle: 'Your workspace identity',
      leading: IconActionButton(
        tooltip: 'Back to dashboard',
        icon: Icons.chevron_left,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.home);
        },
      ),
      headerSpacing: 12,
      subtitleSpacing: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 16),
                    if (_isLoading)
                      Text(
                        'Loading profile...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Unknown user',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.company ?? 'Company not set',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                InfoRow(
                  label: 'Email',
                  value: user?.email ?? '- -',
                ),
                const SizedBox(height: 8),
                const InfoRow(label: 'Role', value: 'IoT Operator'),
                const SizedBox(height: 8),
                const InfoRow(label: 'Region', value: 'Central Hub'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Edit profile'),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Full name',
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Company',
                  controller: _companyController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save changes',
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GhostButton(
            label: 'Log out',
            onPressed: _logout,
          ),
          const SizedBox(height: 8),
          GhostButton(
            label: 'Delete profile data',
            onPressed: _deleteProfile,
          ),
        ],
      ),
    );
  }
}
