import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:splitex/domain/cubits/auth/auth_cubit.dart';
import 'package:splitex/domain/cubits/profile/profile_cubit.dart';
import 'package:splitex/ui/pages/home/home_page.dart';
import 'package:splitex/ui/pages/users/widgets/google_sign_up_button_widget.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: BlocProvider(
        create: (_) => ProfileCubit()..init(),
        child:
            BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
          if (state is ProfileLoadedWithGoogleInfo) {
            return _ProfileLoadedWithGoogleInfoWidget(state: state);
          }

          if (state is ProfileLoadedWithInfo) {
            return _ProfileLoadedWithInfoWidget(state: state);
          }

          if (state is ProfileEditing) {
            return _EditNameWidget(state: state);
          }

          return _EditNameWidget();
        }),
      ),
    );
  }
}

class _ProfileLoadedWithGoogleInfoWidget extends StatelessWidget {
  const _ProfileLoadedWithGoogleInfoWidget({
    Key? key,
    this.state,
  }) : super(key: key);
  final ProfileLoadedWithGoogleInfo? state;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            maxRadius: 25,
            backgroundImage: ((state!.user.photoURL != null)
                ? (NetworkImage(state!.user.photoURL!))
                : AssetImage('assets/blank-profile.jpg')) as ImageProvider<Object>?,
          ),
          SizedBox(height: 8),
          Text('Nombre: ' + state!.user.displayName!),
          SizedBox(height: 8),
          Text('Correo electrónico: ' + state!.user.email!),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              BlocProvider.of<AuthCubit>(context).signOut().then((value) {
                Get.offAll(() => HomePage());
              });
            },
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _EditNameWidget extends StatelessWidget {
  _EditNameWidget({this.state});

  final ProfileEditing? state;

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    if (state != null) {
      nameController.text = state!.name;
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Center(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.width * 0.5,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? name) {
                  if (name!.trim().length == 0) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
                maxLength: 25,
                controller: nameController,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Ingresá tu nombre',
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: context.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context
                        .read<ProfileCubit>()
                        .saveName(nameController.text.trim());
                  }
                },
                child: Text('Guardar'),
              ),
            ),
            GoogleSignUpButtonWidget(),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoadedWithInfoWidget extends StatelessWidget {
  final ProfileLoadedWithInfo? state;

  const _ProfileLoadedWithInfoWidget({
    Key? key,
    this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue,
                ),
                child: Text('Nombre'),
              ),
              SizedBox(width: 12),
              Text(state!.name),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(500),
                  color: Colors.blue,
                ),
                child: IconButton(
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    context.read<ProfileCubit>().enterEditingMode(state!.name);
                  },
                ),
              )
            ],
          ),
          SizedBox(height: 12),
          GoogleSignUpButtonWidget(),
        ],
      ),
    );
  }
}
