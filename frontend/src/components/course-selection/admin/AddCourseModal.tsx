import {
  Box,
  IconButton,
  Modal,
  ModalBody,
  ModalContent,
  ModalOverlay,
  Text,
} from "@chakra-ui/react";
import { useTranslation } from "react-i18next";
import { IoIosCloseCircleOutline } from "react-icons/io";
import AddCourseForm from "./AddCourseForm";

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

const AddCourseModal = (props: Props) => {
  const { t } = useTranslation();

  return (
    <Modal isOpen={props.isOpen} onClose={props.onClose}>
      <ModalOverlay />
      <ModalContent padding="20px">
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Text fontWeight="500" fontSize="xl">
            {t("defineNewCourse")}
          </Text>
          <IconButton
            bg="transparent"
            aria-label="close icon"
            icon={<IoIosCloseCircleOutline size={30} />}
          />
        </Box>
        <ModalBody>
          <AddCourseForm
            onSubmitForm={() => {
              props.onClose();
            }}
          />
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};

export default AddCourseModal;
