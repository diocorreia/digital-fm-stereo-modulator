stereo_fm_mx  DUV(
				//-----------------------------------------------
				// Global signals
				.clock( clock98MHz ),     // master clock, active in posedge
				.reset( reset ),     // master reset, synchronous, active high
				
				//-----------------------------------------------
				// Gains:
				.Ks( Ks ), // 4 bits unsigned
				.Kd( Kd ), // 4 bits unsigned
				.Kp( Kp ), // 4 bits unsigned
				.Kf( Kf ), // 8 bits unsigned
			
				//-----------------------------------------------
				// Audio data in:
				.LEFTin( LEFT_inf ),            // data in, left channel, 18 bits signed
				.RIGHTin( RIGHT_inf ),          // data in, right channel, 18 bits signed

				.clken48kHz( clken48kHz ),    // Clock enable for input sampling rate:
				.clken192kHz( clken192kHz ),  // Clock enable for 4X sampling rate:
				
				//-----------------------------------------------
				// FM Stereo dataout:
				.FMout( FMout )               // data out, FM stereo signal, 24 bits signed
            );
			